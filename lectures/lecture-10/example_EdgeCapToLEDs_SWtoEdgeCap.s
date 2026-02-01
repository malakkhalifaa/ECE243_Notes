# ECE 243 Lecture 10 — Copy Edge Capture to LEDs AND Switches to Edge Capture
# Demonstrates: Edge Capture bits stay 1 until cleared; writing 1 clears that bit,
# writing 0 leaves it unchanged. Push/release keys to set bits; use switches
# to clear specific bits (switch i on -> write 1 to bit i -> that bit clears).
# NOTE: Turn off CPUlator "I/O device Warnings" in settings if it stops with a warning.

.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs,     0xFF200000
.equ SW,       0xFF200040

.text
_start:
    la   t0, KEY_BASE    # set t0 to base KEY port
    la   t1, LEDs        # set t1 to base of LEDR port
    la   t2, SW          # t2 is the switches
copyloop:
    lw   t3, 0xC(t0)    # load Edge Capture Register
    sw   t3, (t1)       # copy into LEDs (so you can watch it)
    lw   t4, 0(t2)      # get the switches
    sw   t4, 0xC(t0)    # copy switches INTO Edge Capture Reg (demonstrates:
                        # writing 1 to a bit clears it; writing 0 leaves it alone)
    j    copyloop
