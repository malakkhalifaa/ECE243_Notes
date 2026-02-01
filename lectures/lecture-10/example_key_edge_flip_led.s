# ECE 243 Lecture 10 — Flip LED 0 on each Key 2 press+release
# Uses Edge Capture Register (polling method).
# Poll until bit 2 set -> flip LED 0 -> clear bit 2 by writing 1 -> repeat.

.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs,     0xFF200000

.text
_start:
    la   t0, KEY_BASE    # set t0 to base KEY port
    la   t1, LEDs        # set t1 to base of LEDR port
    li   t2, 1           # first value of LED 0: on (1)
poll:
    lw   t3, 0xC(t0)     # load Edge Capture Register
    andi t3, t3, 0x4     # select bit for Key 2 (0x4 = bit 2)
    beqz t3, poll        # if 0, nothing changed -> loop
    sw   t2, (t1)        # turn on/off LED 0
    xori t2, t2, 1       # invert t2 for next time (on -> off -> on ...)
    li   t4, 0x4         # value to clear bit 2 (write 1 -> bit becomes 0)
    sw   t4, 0xC(t0)     # clear Edge Capture bit 2 by writing 1 into it
    j    poll            # go back to poll loop
