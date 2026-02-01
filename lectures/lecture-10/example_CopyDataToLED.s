# ECE 243 Lecture 10 — Copy KEY Data Register to LEDs
# Any button press is immediately visible on the LEDs.
# Different from Edge Capture: Data Reg changes when pressed AND when released.

.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs,     0xFF200000

.text
_start:
    la   t0, KEY_BASE    # set t0 to base KEY port
    la   t1, LEDs        # set t1 to base of LEDR port
copyloop:
    lw   t3, 0(t0)      # load Data Register into t3 (same as lw t3, (t0))
    sw   t3, (t1)       # store that into the LEDs
    j    copyloop
