# ECE 243 Lecture 8 — Example: main → sub_1 → sub_2 → sub_3
# Each subroutine pushes ra at start, pops ra before ret.

.global _start
.text

_start:
    la   sp, 0x20000       # initialize stack pointer high in memory
    li   a0, 1
    call sub_1
done:
    j    done

sub_1:
    addi sp, sp, -4        # very first thing: push ra onto stack
    sw   ra, (sp)          # so we can call other subroutines and not lose it!
    call sub_2              # go off to sub_2, then come back
    lw   ra, (sp)          # pop top of stack into ra just before returning
    addi sp, sp, 4
    ret                    # can now return

sub_2:
    addi sp, sp, -4        # very first thing: push ra onto stack
    sw   ra, (sp)          # so we can call other subroutines and not lose it!
    call sub_3              # go off to sub_3, then come back
    lw   ra, (sp)          # pop top of stack into ra
    addi sp, sp, 4
    ret                    # can now return (pc <- ra — the correct one!)

sub_3:
    addi sp, sp, -4        # very first thing: push ra onto stack
    sw   ra, (sp)          # (sub_3 could call another subroutine here)
    # ... body of sub_3 ...
    lw   ra, (sp)          # pop top of stack into ra
    addi sp, sp, 4
    ret                    # can now return
