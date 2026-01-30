# ECE 243 Lecture 7 — Example: call / ret, ra, pc
# Equivalent C:  x = my_sub(3);  z = my_sub(4);   with my_sub(p) { return p+p; }

.global _start
.text

_start:
    li   a0, 3           # a0 <- 3 (parameter for first call)
    call my_sub          # ra <- pc (next instr); pc <- my_sub
                         # return value comes back in a0
next:
    li   a0, 4           # a0 <- 4 (parameter for second call)
    call my_sub          # ra <- pc (different!); pc <- my_sub
done:
    j    done            # infinite loop (program "stops" here)

# --- subroutine my_sub ---
my_sub:
    add  a0, a0, a0      # a0 <- a0 + a0 (p + p), result in a0
    ret                  # pc <- ra  (go back to instruction after the call)
                         # After call #1: goes to next
                         # After call #2: goes to done
