# 2025 Midterm — Q3(a) [4 marks]

## Question

Translate the following C code **as directly as possible** into Nios V assembly. You **must use a register** for the variable **`i`** (do not use a memory location for `i`).

```c
int X[10];
for (int i = 0; i < 10; i++)
    X[i] = i;
```

---

## Your answer:

_(Write your assembly below.)_

```asm

```

---

## Detailed explanation / solution

- **`i`** in a register (e.g. **t0**).
- **Base address of X** in a register (e.g. **t2**); advance by 4 each iteration (word = 4 bytes).
- **Loop:** store **i** at **X[i]**, then increment **i** and pointer; branch if **i < 10**.

**Nios V / RISC-V style:**

```asm
_start:
    li   t0, 0          # i = 0
    li   t1, 10         # loop bound
    la   t2, X          # address of X[0]

loop:
    sw   t0, (t2)       # X[i] = i
    addi t0, t0, 1      # i++
    addi t2, t2, 4      # next word
    blt  t0, t1, loop   # if (i < 10) goto loop

done:
    j    done           # optional: halt

X:
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
```

**Notes:**

- **`la t2, X`** loads the address of the first element; **`sw t0, (t2)`** stores at that address; **`addi t2, t2, 4`** moves to the next word.
- **`blt t0, t1, loop`** implements **i < 10** (branch if t0 < t1).
- **`.word 0,...`** reserves 10 words for **X**; initial value 0 is fine since we overwrite with **i**.
