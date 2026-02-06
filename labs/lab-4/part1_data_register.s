# ECE243 Lab 4 — Part 1: KEY press and release using Data Register only
# Wait for KEY0 press (poll until bit 0 = 1), then wait for release (poll until bit 0 = 0),
# then toggle LED0. Repeat forever.
# Addresses: LEDs 0xFF200000, KEY base 0xFF200050, Data reg at offset 0.

.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs,     0xFF200000

.text
_start:
    la   t0, KEY_BASE       # t0 = KEY parallel port base
    la   t1, LEDs           # t1 = LED parallel port base
    li   t2, 1              # t2 = current LED0 state (1 = on); will toggle

main_loop:
    # --- Wait for KEY0 PRESS: poll until Data Register bit 0 = 1 ---
wait_press:
    lw   t3, 0(t0)          # load Data Register (offset 0)
    andi t3, t3, 0x1        # keep only KEY0 (bit 0)
    beqz t3, wait_press     # if 0, not pressed -> keep polling

    # --- Wait for KEY0 RELEASE: poll until Data Register bit 0 = 0 ---
wait_release:
    lw   t3, 0(t0)          # load Data Register again
    andi t3, t3, 0x1        # keep only KEY0
    bnez t3, wait_release   # if 1, still pressed -> keep polling

    # --- Key was pressed and released: toggle LED0 ---
    sw   t2, (t1)           # write current LED state to LEDs
    xori t2, t2, 1          # flip bit 0 for next time (on <-> off)
    j    main_loop          # repeat
