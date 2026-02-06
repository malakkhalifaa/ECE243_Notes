# ECE243 Lab 4 — Part 3: Interval timer, LED sequence every 0.25 s
# Change the 10 LEDs every 0.25 seconds through a 5-step sequence, then repeat.
# Timer: base 0xFF202000, 100 MHz; 0.25 s = 25,000,000 ticks.
# LEDs: 0xFF200000, bits 0–9 = LEDR0–LEDR9.
# Register layout: Status 0, Control 4, Period low 0x8, Period high 0xC.
# Poll TO bit in Status; clear TO by writing 0 to Status.

.global _start
.equ TIMER_BASE, 0xFF202000
.equ COUNTER_DELAY, 25000000   # 0.25 s at 100 MHz
.equ LEDs, 0xFF200000

.text
_start:
    la   t5, TIMER_BASE    # t5 = timer base
    sw   zero, 0(t5)       # clear TO bit in Status

    li   t0, COUNTER_DELAY # 32-bit period for 0.25 s
    sw   t0, 0x8(t5)       # store low 16 bits to Period low
    srli t1, t0, 16       # high 16 bits
    sw   t1, 0xC(t5)      # store high 16 bits to Period high

    li   t0, 0b0110       # CONT (bit 1) + START (bit 2) — run continuously
    sw   t0, 4(t5)        # write Control register

    li   t2, 0            # index into patterns (0, 4, 8, 12, 16)
    la   t3, patterns     # base of pattern table
    la   t4, LEDs         # LED base

tloop:
    add  t6, t3, t2       # address of current pattern word
    lw   t1, (t6)         # load pattern (only low 10 bits used)
    sw   t1, (t4)         # drive LEDs

    # --- Poll until TO = 1 ---
ploop:
    lw   t0, 0(t5)        # load Status register (offset 0)
    andi t0, t0, 0x1      # keep only TO bit (bit 0)
    beqz t0, ploop        # if 0, keep polling

    sw   zero, 0(t5)      # clear TO for next cycle

    addi t2, t2, 4        # next pattern (each pattern is one word)
    li   t0, 20           # 5 patterns × 4 bytes = 20
    blt  t2, t0, tloop    # if index < 20, show next pattern
    li   t2, 0            # else wrap to first pattern
    j    tloop

# 5 patterns: 10 bits each for LEDR9..LEDR0
# 0b1111111111, 0b1111111110, 0b1111110000, 0b1110000000, 0b0000000000
patterns:
    .word 0x3FF, 0x3FE, 0x3F0, 0x380, 0x0
