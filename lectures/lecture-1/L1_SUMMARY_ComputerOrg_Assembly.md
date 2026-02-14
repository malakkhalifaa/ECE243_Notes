# ECE 243 Lecture #1 — Summary Sheet

## Lecture context
- **Review:** Computer is a fundamental invention; ECE 243 covers its fundamentals. When something goes wrong while building, treat it as a chance to learn **debugging** — a core engineering skill.
- **Work-in-flight:** Find a lab partner in your same lab period; Lab 1 (next week) is posted; after this lecture you can do Parts I and II (Part I: serious discussion with partner).
- **Today:** Computer organization and assembly-language programming.

---

## 1. A computer has three parts

| Part | Role |
|------|------|
| **Central Processing Unit (CPU)** | Does computation and control. |
| **Memory** | Stores variables, data structures, **and the program being executed**. |
| **Input/Output (I/O)** | Communicates with the outside world (keyboard, screen, sensors, network, etc.). |

---

## 2. Processor / CPU (Nios V)
- We use the **Altera Nios V** processor (broadly **RISC-V**).
- **Computation** — done by the **Arithmetic Logic Unit (ALU)**.
- **Decisions / control** — done by a **Finite State Machine (FSM)**.
- **Data** — operations are done on **processor registers** (same idea as D-type registers in ECE 241).
- **Nios V** has **32 32-bit registers**: **x0, x1, x2, … x31**.
- Each register has a **second name** (e.g. x5 = **t0**, x6 = **t1**). **We use these second names** in this course; full list is on page 1–5 of the lecture / in Nios_V_intro.pdf (page 2).

---

## 3. Memory
- Stores **variables** and **all data structures**.
- Also stores **the program being executed** — this is subtle and important.

---

## 4. Input/Output
- Communication with the **outside world**.
- Examples: keyboard, screen, microphone, camera, network, sensors (e.g. accelerometer, gyroscope, magnetometer, light).

---

## 5. Programming at the core: Assembly language
- At the **most basic level**, the system is programmed **not** in C/C++/Python/Rust/JavaScript but in **assembly language**.
- A **compiler** translates **C → assembly**.
- **Assembly** is translated (e.g. by an assembler) into **machine code** — **numbers** that represent each instruction. (Numbers are what digital circuits work with.)

---

## 6. C to assembly by hand (example)
C code:
```c
int A, B, C, D;
A = 1;
B = 8;
C = A + B;
D = B - A;
```
- We **assign variables to registers**: e.g. A → **t0**, B → **t1**, C → **t2**, D → **t3**.
- **Operations** in this processor are performed **only on registers** (not directly on memory; we must load into a register first).

| C | Assembly | What the instruction does |
|---|----------|---------------------------|
| A = 1 | `li t0, 1` | Load immediate: t0 ← 1 |
| B = 8 | `li t1, 8` | t1 ← 8 |
| C = A + B | `add t2, t0, t1` | t2 ← t0 + t1 |
| D = B - A | `sub t3, t1, t0` | t3 ← t1 − t0 |

Then an **infinite loop** (e.g. `iloop: j iloop`) so the processor doesn’t run past the end of the program.

---

## 7. Where we run programs
- **Nios V** is programmed into the **FPGA** on the **DE1-SoC** board (from ECE 241).
- **Before** using the real board in lab, we use **CPUlator** — a **web-based simulation** of the DE1-SoC Nios V system — to run and **debug** our code.

---

## 8. CPUlator
- Simulates the DE1-SoC (e.g. switches, LEDs, VGA).
- **Load** program → **Assemble & load** → view **Disassembly** (machine code and addresses).
- **Single-step** through the program and **observe registers** to check that each instruction does what you expect.

---

## 9. Debugging (lecture emphasis)
- **“Do I understand what this instruction is supposed to do?”**
- **At the beginning, run one instruction at a time** and see if your assumptions are correct.
- **Always have assumptions/expectations, then check.** Never assume you know what is happening until it’s proven right.
- Doing this carefully in Lab 1 and 2 sets you up well as an engineer.

---

## 10. Register “second names” (Nios V)
- **x0** = zero (constant 0).
- **x1** = ra (return address).
- **x2** = sp (stack pointer).
- **x5** = t0, **x6** = t1, **x7** = t2, … (temporaries).
- **x10** = a0, **x11** = a1, … (arguments/return).
- **x8** = s0, **x9** = s1, … (saved).
- Full table: **Nios_V_intro.pdf**, page 2.

---

## 11. Example program (from lecture)
```asm
.global _start
/* A is t0, B is t1, C is t2 and D is t3 */
_start:
    li   t0, 1       # A = 1
    li   t1, 8       # B = 8
    add  t2, t0, t1  # C = A + B
    sub  t3, t1, t0  # D = B - A
iloop:
    j    iloop       # infinite loop
```

---

## Quick reference
| Item | Meaning |
|------|--------|
| **CPU** | Processor: ALU + control; operations on registers. |
| **Memory** | Variables, data, **and the program**. |
| **I/O** | Outside world. |
| **Assembly** | Human-readable, one-to-one with machine code. |
| **Machine code** | Numbers representing instructions. |
| **Nios V** | 32 registers x0–x31; use **second names** (t0, t1, a0, s0, …). |
| **CPUlator** | Web simulator for DE1-SoC Nios V; single-step to debug. |
| **Debugging** | One instruction at a time; check assumptions. |
