# 2025 Midterm — Q2(c) [2 marks]

## Question

The **`sw`** instruction in part (b) overwrites **4 bytes** in memory. In the table below, give in **hexadecimal** the **starting address** of those four bytes and their **final values**. The leftmost cell is the word-aligned address; the other cells are bytes at +0, +1, +2, +3.

| ADDRESS | +0 | +1 | +2 | +3 |
|---------|----|----|----|----|
|        |    |    |    |    |

---

## Your answer:

_(Fill in the table.)_

---

## Detailed explanation / solution

- In part (b), **`sw s0, 1(a0)`** with **a0 = 0x1027** stores the word in **s0** at address **0x1027 + 1 = 0x1028**.
- **s0** at that time was **0x08070605** (from the previous **`lw s0, -7(a0)`**).
- Little-endian: store 0x08070605 as:
  - byte at 0x1028: **0x05**
  - byte at 0x1029: **0x06**
  - byte at 0x1030: **0x07**
  - byte at 0x102B: **0x08**
- The **starting (word-aligned) address** of that 4-byte block is **0x1028**.

**Filled table:**

| ADDRESS | +0 | +1 | +2 | +3 |
|---------|----|----|----|----|
| 0x1028  | 0x05 | 0x06 | 0x07 | 0x08 |
