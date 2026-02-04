# 2025 Midterm — Q3(c) [5 marks]

## Question

Convert the following C code into assembly. You must **place the variables `x`, `y`, and `p` in memory** (they may not exist only in registers). Recall: **`*`** dereferences a pointer; **`&`** gives the address of a variable.

```c
int x = 36;
int y;
int *p;
p = &x;
y = *p + 5;
```

---

## Your answer:

_(Write your assembly below.)_

```asm

```

---

## Detailed explanation / solution

- **x** in memory, value **36**.
- **y** in memory (value to be computed).
- **p** in memory (will hold the **address of x**).
- **p = &x** → load address of **x** and store it in **p**.
- **y = *p + 5** → load word from address in **p** (i.e. **x**), add 5, store result in **y**.

**Nios V / RISC-V:**

```asm
    la   t0, x          # t0 = &x
    la   t1, y          # t1 = &y
    la   t2, p          # t2 = &p

    sw   t0, (t2)       # p = &x  (store address of x into p)

    lw   t3, (t0)       # t3 = *p  (load x)
    addi t3, t3, 5      # t3 = *p + 5
    sw   t3, (t1)       # y = *p + 5

x:  .word 36
y:  .word 0
p:  .word 0
```

**Notes:**

- **`la t0, x`** loads the address of **x**; **`sw t0, (t2)`** stores that address into **p**.
- **`lw t3, (t0)`** loads the word at the address in **t0** (i.e. **x** = 36). Then **addi t3, t3, 5** gives 41; **sw t3, (t1)** stores 41 in **y**.
- Variables **x**, **y**, **p** all reside in the `.word` data section; only temporaries (addresses, computed value) are in registers.
