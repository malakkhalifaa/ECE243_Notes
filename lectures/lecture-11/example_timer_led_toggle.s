# ECE 243 Lecture 11 — Timer: count down from 100,000,000 (1 s at 100 MHz),
# toggle LED 0 on and off each time the timer reaches zero.
# Uses polling on the TO (Time Out) bit in the Status register.

.global _start
.equ TIMER_BASE,    0xFF202000
.equ COUNTER_DELAY, 100000000   # 1 second at 100 MHz clock
.equ LEDs,          0xFF200000

.text
_start:
    la   t5, TIMER_BASE       # base address of timer
    sw   zero, 0(t5)         # clear the TO (Time Out) bit in case it is on

    li   t0, COUNTER_DELAY   # load the 32-bit delay value
    sw   t0, 0x8(t5)         # store low 16 bits to Counter start value (low)
    srli t1, t0, 16          # shift right 16: upper 16 bits -> lower 16 of t1
    sw   t1, 0xc(t5)         # store high 16 bits to Counter start value (high)

    li   t0, 0b0110          # CONT (continuous) + START — start and run continuously
    sw   t0, 4(t5)           # store into Control register (offset 4)

    la   t6, LEDs
    li   t2, 1                # used to toggle LED 0: start at on (1)

tloop:
    sw   t2, (t6)             # store current value to LED 0
    xori t2, t2, 1            # flip bit for next time (on -> off -> on ...)

ploop:
    lw   t0, 0(t5)            # load Status register
    andi t0, t0, 0b1          # mask: keep only TO bit (bit 0)
    beqz t0, ploop            # if TO is 0, keep polling

    sw   zero, 0(t5)         # clear TO bit for next countdown cycle
    j    tloop                # go back: toggle LED and wait again
