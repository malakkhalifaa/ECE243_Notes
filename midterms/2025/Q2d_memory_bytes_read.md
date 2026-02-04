# 2025 Midterm — Q2(d) [2 marks]

## Question

When the **first three instructions** of part (b) execute, how many **bytes** are **read from memory** in total? Include **all** accesses the processor performs during their execution (instruction fetches and data accesses).

---

## Your answer:

_(Number and brief explanation.)_

---

## Detailed explanation / solution

The first three instructions of part (b) are:

1. **`lb s0, 0(a0)`**
2. **`lh s0, 3(a0)`**
3. **`lw s0, -7(a0)`**

**Instruction fetches (reads):**

- Each instruction is one word (4 bytes). Three instructions → **3 × 4 = 12 bytes** read for fetches.

**Data reads:**

- **`lb s0, 0(a0)`** — 1 byte read.
- **`lh s0, 3(a0)`** — 2 bytes read.
- **`lw s0, -7(a0)`** — 4 bytes read.

**Total bytes read from memory:**  
12 + 1 + 2 + 4 = **19 bytes**.

(Exam solution: 3×4 (fetches) + 1 (lb) + 2 (lh) + 4 (lw) = 19.)
