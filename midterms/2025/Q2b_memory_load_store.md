# 2025 Midterm — Q2(b) [4 marks]

## Question

Assume each byte in a Nios V processor’s memory is as in the table:

| ADDRESS | +0 | +1 | +2 | +3 |
|---------|----|----|----|----|
| 0x101C  | 0x01 | 0x02 | 0x03 | 0x04 |
| 0x1020  | 0x05 | 0x06 | 0x07 | 0x08 |
| 0x1024  | 0x11 | 0x22 | 0x33 | 0x44 |
| 0x1028  | 0x55 | 0x66 | 0x77 | 0x88 |
| 0x102C  | 0x99 | 0xaa | 0xbb | 0xcc |
| 0x1030  | 0xdd | 0xee | 0xff | 0x00 |

**Assume `a0 = 0x1027`.** For each instruction below, give the **contents of the indicated register** after the instruction executes (in hex), or explain why it does **not** execute successfully.

```asm
lb   s0, 0(a0)    // s0 = ?
lh   s0, 3(a0)    // s0 = ?
lw   s0, -7(a0)   // s0 = ?
sw   s0, 1(a0)    //
lw   s0, 2(a0)    // s0 = ?
```

---

## Your answer:

_(Fill in each comment or explain.)_

---

## Detailed explanation / solution

- **a0 = 0x1027.** Little-endian: byte at lowest address is LSB.
- **`lb s0, 0(a0)`** — load **byte** from 0x1027 → byte is **0x88**. Sign-extend → **s0 = 0xFFFFFF88** (or 0x00000088 if unsigned; Nios V/RISC-V `lb` is sign-extending, so **0xFFFFFF88**).
- **`lh s0, 3(a0)`** — load **halfword** from address 0x1027+3 = **0x102A**. Halfword = bytes at 0x102A, 0x102B → 0x7788 (0x88 at 0x102A, 0x77 at 0x102B). Sign-extend → **s0 = 0xFFFF8877**.
- **`lw s0, -7(a0)`** — load **word** from 0x1027−7 = **0x1020**. Word at 0x1020 = 0x08070605 → **s0 = 0x08070605**.
- **`sw s0, 1(a0)`** — store **word** in **s0** to address 0x1027+1 = **0x1028**. So the 4 bytes of **s0** (which is 0x08070605) are written at 0x1028…0x102B. No register result to fill; this sets up memory for the next part.
- **`lw s0, 2(a0)`** — load **word** from 0x1027+2 = **0x1029**. On Nios V/RISC-V, **word loads must be aligned to 4 bytes**. 0x1029 is **not** divisible by 4 → **misaligned access** → instruction does **not** execute successfully (trap/fault).

**Summary:**

- `lb s0, 0(a0)` → **s0 = 0xFFFFFF88** (or 0x00000088 if treating as unsigned).
- `lh s0, 3(a0)` → **s0 = 0xFFFF8877**.
- `lw s0, -7(a0)` → **s0 = 0x08070605**.
- `sw s0, 1(a0)` → (no register; stores to 0x1028).
- `lw s0, 2(a0)` → **does not execute successfully** — **misaligned word access** (address 0x1029).
