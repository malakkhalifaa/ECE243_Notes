# ECE 243 Lecture #3 — Summary Sheet

## Lecture context
- **Work-in-flight:** Find partner in your lab period (Soliman Ali / head TA); Lab 1 prep; new rubric on Quercus.
- **Last day:** Lab 1 (five parts), loops and conditional branches.
- **Today:** **Memory organization** in the Nios V processor — how programs and data are organized in memory, and an example program.

---

## 1. Recall: from C to execution
- Software is compiled into **assembly** (e.g. `li t0, 1`) — human-readable.
- The **assembler** translates assembly into **machine code** (numbers) and **places the code into memory**.
- The processor **executes** by **reading instructions from memory**.

---

## 2. Goal of the example
- An assembly program that **adds three numbers that are in memory**. The program itself places those numbers in memory (like initializing an array in C).

---

## 3. Nios V as a 32-bit processor
- **Registers** are **32 bits** wide (like 32 D-type flip-flops).
- **Addressable memory:** **2^32** locations (~4 billion).
- **Word size** = **32 bits** — the typical amount of information accessed from memory at one time.
- You can also access **less** than a word:
  - **8 bits** = **byte**
  - **16 bits** = **halfword**
  - **32 bits** = **word**

---

## 4. Byte-addressable memory
- The Nios V is **byte addressable**: **every byte (8 bits) has its own address**.
- The processor often accesses a **whole word** at once — **4 bytes** in **4 consecutive addresses**.
- **Little Endian** (Nios V): The **least significant byte (LSB)**, bits 0–7, has the **same address as the word**. So Word 0’s LSB is at address 0; Word 1’s LSB is at address 0x4.
- **Big Endian** (some other processors): The **most significant byte (MSB)** comes first. Processors that communicate must agree on which convention is used.

---

## 5. Example: add three numbers in memory
- **Assumption:** The three numbers are in **consecutive word** addresses.
- **Values:** decimal **10, 20, 30** (hex **0xa, 0x14, 0x1e**).
- **Addresses** (example): **0x2c, 0x30, 0x34** (one word apart). The **answer** is stored at **0x38**.

---

## 6. Code and data in the same memory
- The **code** (instructions, as machine code) sits in memory — **consecutive instructions in consecutive locations**.
- The **data** (variables, constants) also sits in **the same memory**, right next to the code.

---

## 7. Two questions and answers

| Question | Answer |
|----------|--------|
| How do you put numbers like 10, 20, 30 into memory? | Use an **assembler directive** such as **`.word`** — like `int list[3] = {10, 20, 30};` in C. |
| How do you know the addresses of that data? | Use a **label** (e.g. **list**). The **assembler** keeps track of the address; you refer to the label and the assembler substitutes the address. |

---

## 8. The `.word` directive
- **`.word 10`** tells the assembler to **put the constant 10 into memory** and to **reserve a full word** (32 bits = 4 bytes = 4 addresses).
- Several `.word` values in a row occupy **consecutive words** (addresses 4 bytes apart).

---

## 9. Labels and “addresses of data”
- Putting a **label** (e.g. **list**) in front of a `.word` tells the assembler: “let the programmer refer to **this memory location** by name.”
- The **label** is the **address** of that location — a number the assembler knows and substitutes when you use the label.
- The address **changes** if you add or remove code/data above it, so we use the **symbol** and let the assembler keep track.
- In assembly we **do not have variable types** (int, float, char). We only have “how many bits” and whether we treat the bits as **signed** (2’s complement) or **unsigned**. **list** is not a variable; it is the **address** of where data lives — like a **pointer** in C.

---

## 10. Pointers and dereferencing (core idea)
- The program illustrates the **assembly equivalent of dereferencing a pointer** in C.
- **`la t0, list`** — load the **address** of **list** into **t0** (t0 = 0x2c). So **t0** holds a **pointer**.
- **`lw t1, (t0)`** — **load word** from the memory address **in t0**. So **t1 ← [t0]** — like **t1 = *ptr** in C. The **(t0)** means “the address in register t0.”
- **`lw t2, 4(t0)`** — load from address **t0 + 4**. So **t2 ← [t0 + 4]**.
- **`lw t3, 8(t0)`** — **t3 ← [t0 + 8]**.
- **`sw t2, (t0)`** — **store word**: write the contents of **t2** into the memory address **in t0**. So **[t0] ← t2**.

---

## 11. Load and store (summary)
- **la rd, label** — load **address** of label into **rd** (rd = address).
- **lw rd, offset(rs1)** — **load word**: rd ← contents of memory at address **rs1 + offset**.
- **sw rs1, offset(rs2)** — **store word**: memory at **rs2 + offset** ← **rs1**.

We **cannot** do arithmetic directly on memory; we must **load** into a register, compute, then **store** back if needed.

---

## 12. Example program (add three numbers)
```asm
.global _start
_start:
    la   t0, list      # t0 <- address of list (e.g. 0x2c)
    lw   t1, (t0)      # t1 <- [t0] = 10
    lw   t2, 4(t0)     # t2 <- [t0+4] = 20
    lw   t3, 8(t0)     # t3 <- [t0+8] = 30
    add  t2, t2, t1    # t2 <- 10 + 20 = 30
    add  t2, t2, t3    # t2 <- 30 + 30 = 60
    la   t0, answer    # t0 <- address of answer (e.g. 0x38)
    sw   t2, (t0)      # [t0] <- t2  (store 60 at answer)
done:
    j    done
list:   .word 10
        .word 20
        .word 30
answer: .word 0
```

---

## Quick reference
| Item | Meaning |
|------|--------|
| **32-bit processor** | 32-bit registers; 2^32 addressable bytes; word = 32 bits. |
| **Byte addressable** | Every byte has its own address. |
| **Little Endian** | LSB of a word has the same address as the word. |
| **.word** | Put constant(s) in memory; reserve one word (4 bytes) per value. |
| **Label** | Name for an address; assembler keeps track. |
| **la rd, label** | Load **address** of label into rd. |
| **lw rd, offset(rs)** | Load **word**: rd ← [rs + offset]. |
| **sw rs, offset(rt)** | Store **word**: [rt + offset] ← rs. |
| **Pointer / dereference** | la = “address of”; lw/sw (reg) = “contents of” that address. |
