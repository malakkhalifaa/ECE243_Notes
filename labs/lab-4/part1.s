# ==============================================================================
# ECE 243 Lab 4 — Part I: LED control with 4 KEY pushbuttons (Data reg only)
# ==============================================================================
# Written by Hamda Armeen
# This program controls the LEDs using the 4 KEY push buttons with polling and
# release detection (labels and loops, Data register only — no Edge-capture).
#
# KEY0 → set display to 1   KEY1 → increment (max 15)   KEY2 → decrement (min 1)
# KEY3 → blank (0); then any other KEY brings display back to 1.
# ==============================================================================

.global _start
.equ KEYS, 0xFF200050    # KEY Data register (base address)
.equ LEDs, 0xFF200000    # 10 red LEDs

.text
_start:
    la   t0, KEYS        # t0 = address of KEY Data register
    la   t2, LEDs        # t2 = address of LEDs

    li   s2, 0           # s2 = 0 (for "compare to 0" and blank)
    li   t6, 15          # t6 = 15 (max value; don't go above 15)

    li   s1, 1           # s1 = value on LEDs (1..15 or 0=blank) — MUST init
    sw   s1, 0(t2)       # show 1 on LEDs at start (per spec)

# ------------------------------------------------------------------------------
# POLL: read KEY Data register until at least one key is pressed
#   bit 0 = KEY0, bit 1 = KEY1, bit 2 = KEY2, bit 3 = KEY3
# ------------------------------------------------------------------------------
poll:
    lw   t1, (t0)        # t1 = KEY Data register
    beqz t1, poll        # if no key pressed, keep polling

    # When display is blank (0), any key should show 1 — go to key0
    beqz s1, key0

    andi t3, t1, 0x1     # bit 0 = KEY0
    bnez t3, key0
    andi t3, t1, 0x2     # bit 1 = KEY1
    bnez t3, key1
    andi t3, t1, 0x4     # bit 2 = KEY2
    bnez t3, key2
    andi t3, t1, 0x8     # bit 3 = KEY3
    bnez t3, key3
    j    poll

key0:
    li   s1, 1           # keep s1 in sync with display (value = 1)
    sw   s1, 0(t2)       # display 1 on LEDs
    j    release_poll

key1:
    bge  s1, t6, poll    # if already 15, don't increment
    addi s1, s1, 1
    sw   s1, 0(t2)
    j    release_poll

key2:
    beqz s1, key0        # if blank (0), spec says KEY2 brings back to 1
    li   t4, 1
    ble  s1, t4, poll    # if s1 is 1, don't decrement (min is 1)
    addi s1, s1, -1
    sw   s1, 0(t2)
    j    release_poll

key3:
    sw   s2, 0(t2)       # s2 = 0 → blank the display
    li   s1, 0           # s1 = 0 so we know display is blank
    j    release_poll

release_poll:
    lw   t1, (t0)        # read KEY Data again
    bnez t1, release_poll # wait until ALL keys released (t1 = 0)
    j    poll            # then go back to poll for next press
