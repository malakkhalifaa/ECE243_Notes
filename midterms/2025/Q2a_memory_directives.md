# 2025 Midterm — Q2(a) [7 marks]

## Question

Consider the following Nios V code sequence of assembly directives:

```asm
.equ SOMETHING, 15
one:   .hword 12
       .hword 0b1111111100000000   # eight 1s and eight 0s
two:   .word -1, 0x87654321, three
three: .hword 0x1234, 10
four:  .byte SOMETHING+2, 12, 0x80, -2
```

Assume that the assembler places the above data **starting at address 0x1000**. Fill in the table below with the **memory values** that the above directives generate. Each cell corresponds to a **single byte** in memory. Use **hexadecimal** values. Mark any memory not defined by these statements with **"U"**.

| ADDRESS | +0 | +1 | +2 | +3 |
|---------|----|----|----|----|
| 0x1000  |    |    |    |    |
| 0x1004  |    |    |    |    |
| 0x1008  |    |    |    |    |
| 0x100c  |    |    |    |    |
| 0x1010  |    |    |    |    |
| 0x1014  |    |    |    |    |
| 0x1018  |    |    |    |    |

---

## Your answer:

_(Fill in the table above or here.)_

---

## Detailed explanation / solution

- **Nios V / RISC-V:** Little-endian: least significant byte at lowest address.
- **`.equ SOMETHING, 15`** — no bytes in memory; `SOMETHING+2` = 17 = 0x11.
- **`one:`** — start at 0x1000.
  - **`.hword 12`** → 0x000C → 0x1000: **0x0C**, 0x1001: **0x00**.
  - **`.hword 0b1111111100000000`** = 0xFF00 → 0x1002: **0x00**, 0x1003: **0xFF**.
- **`two:`** at 0x1004.
  - **`.word -1`** → 0xFFFFFFFF → 0x1004: **0xFF**, **0xFF**, **0xFF**, **0xFF**.
  - **`.word 0x87654321`** → 0x1008: **0x21**, **0x43**, **0x65**, **0x87**.
  - **`.word three`** — address of label `three` = **0x1010** (first byte of the next directive) → 0x100C: **0x10**, **0x10**, **0x00**, **0x00** (32-bit little-endian).
- **`three:`** at 0x1010.
  - **`.hword 0x1234`** → 0x1010: **0x34**, 0x1011: **0x12**.
  - **`.hword 10`** → 0x000A → 0x1012: **0x0A**, 0x1013: **0x00**.
- **`four:`** at 0x1014.
  - **`.byte SOMETHING+2`** = 17 = **0x11**.
  - **`.byte 12`** = **0x0C**.
  - **`.byte 0x80`** = **0x80**.
  - **`.byte -2`** = 0xFE → **0xFE**.
- **0x1018** and beyond: not defined → **U**.

**Filled table:**

| ADDRESS | +0   | +1   | +2   | +3   |
|---------|------|------|------|------|
| 0x1000  | 0x0c | 0x00 | 0x00 | 0xFF |
| 0x1004  | 0xff | 0xff | 0xff | 0xff |
| 0x1008  | 0x21 | 0x43 | 0x65 | 0x87 |
| 0x100c  | 0x10 | 0x10 | 0x00 | 0x00 |  (address of three = 0x1010)
| 0x1010  | 0x34 | 0x12 | 0x0a | 0x00 |
| 0x1014  | 0x11 | 0x0c | 0x80 | 0xFE |
| 0x1018  | U   | U    | U    | U    |

(Note: In the original exam, the label `two` is at 0x1004 and the first word there is -1; the address 0x100c holds the value `three` = 0x0000100C, so +0=0x0C, +1=0x10, +2=0x00, +3=0x00. The solution sheet shows 0x1010 0x00 0x00 for the last two bytes of `three` — that would be if the address were 0x1000; with 0x100C, bytes are 0x0C, 0x10, 0x00, 0x00. The label three is at 0x1010, so 0x100C holds 0x00001010; bytes 0x10, 0x10, 0x00, 0x00 are correct for “address of three” = 0x100C.)
