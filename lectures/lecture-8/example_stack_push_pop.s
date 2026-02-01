# ECE 243 Lecture 8 — Example: push and pop
# Initialize sp, push a word, pop it back.

.global _start
.text

_start:
    la   sp, 0x20000       # initialize stack pointer (stack empty)
    li   t0, 0x1234f678    # value to push (may be two instructions to fit word)
    addi sp, sp, -4        # make room: sp <- sp - 4
    sw   t0, (sp)          # push t0 onto stack (does not change t0)
    # ... stack now has one word at top ...
    lw   t1, (sp)          # pop top of stack into t1 (t1 <- 0x1234f678)
    addi sp, sp, 4         # remove item from stack; if sp = 0x20000, stack empty
done:
    j    done
