# ECE 243 Lecture 9 — Example: Memory-Mapped I/O
# Continuously copy the 10 switches (input) to the 10 LEDs (output).
# lw/sw used for both I/O and memory; hardware knows by address what you want.

.global _start
.equ LEDs, 0xFF200000    # .equ sets symbol LEDs to that number (ease of reading)
.equ SW,  0xFF200040     # switches address

.text
_start:
    la   t0, LEDs        # get LED address into t0: t0 <- 0xFF200000
    la   t1, SW          # get SW  address into t1: t1 <- 0xFF200040
loop:
    lw   t2, (t1)        # load the 10 switches value into t2
    sw   t2, (t0)        # store the 10 values into the LEDs
    j    loop            # do it over and over
