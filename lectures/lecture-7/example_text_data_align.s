# ECE 243 Lecture 7 — Example: .text, .data, .align
# Demonstrates proper use of directives so word load doesn't crash

.global _start
.text                    # what follows is code, not data
_start:
    la   t0, myword      # load address of myword into t0
    lw   t1, (t0)        # load word at that address into t1
done:
    j    done            # infinite loop (typical end of program)

.data                    # what follows is data only
mybyte:
    .byte 0x2a           # 1 byte at (possibly unaligned) address
.align 2                 # align next label to 2^2 = 4 byte boundary
myword:
    .word 0x1a54dd33     # 4-byte word; must be 4-byte aligned for lw

# Note: Without .align 2, myword could be at an unaligned address
# and lw would cause a fault/crash.
