# Lecture 1 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #1**.

---

## Lecture context

**Q:** What two points from the course intro video does the lecture review?

**A:** (1) The computer is a marvelous invention; ECE 243 is about its fundamentals. (2) When something goes wrong while building, it’s an opportunity to learn **debugging** — a core engineering skill.

---

**Q:** After this lecture, which parts of Lab 1 can you do? What is Part I about?

**A:** You should be able to do **Parts I and II** (but not III–V). **Part I** is a serious discussion with your lab partner.

---

## Computer organization

**Q:** What are the three parts of a computer?

**A:** (1) **Central Processing Unit (CPU)** — the processor. (2) **Memory** — stores data and the program. (3) **Input/Output (I/O)** — communication with the outside world.

---

**Q:** What does the CPU do? What two main blocks are mentioned?

**A:** The CPU performs **computation** (using the **ALU** — Arithmetic Logic Unit) and **decisions/control** (using a **Finite State Machine**). The actual operations happen on **processor registers**.

---

**Q:** How many registers does Nios V have? What are they called? Which names do we use in this course?

**A:** Nios V has **32** registers, each **32 bits**. They are named **x0, x1, …, x31**. We use their **second names** (e.g. t0, t1, a0, s0, ra, sp) in this course.

---

**Q:** What does memory store (two main things)?

**A:** Memory stores **variables and data structures**, and it also stores **the program being executed**.

---

**Q:** What is the I/O unit for? Give two examples.

**A:** The I/O unit is for **communication with the outside world**. Examples: keyboard, screen, microphone, camera, network, sensors (e.g. accelerometer, gyroscope, light).

---

## Assembly and machine code

**Q:** At the most basic level, how is the computer programmed? What language is it not?

**A:** At the most basic level it is programmed in **assembly language** — not in C, C++, Python, Rust, or JavaScript.

---

**Q:** What translates C code into assembly? What are assembly instructions translated into, and why numbers?

**A:** A **compiler** translates C into assembly. Assembly is translated into **machine code** — **numbers** that represent each instruction. Digital circuits work with numbers, so instructions are encoded as numbers.

---

**Q:** In the C example (A=1, B=8, C=A+B, D=B−A), why do we put A, B, C, D in registers (t0, t1, t2, t3)?

**A:** Because the **processor only performs operations on registers**, not directly on memory. We must put values in registers (e.g. after loading from memory) before we can add, subtract, etc.

---

**Q:** Write the assembly instruction that puts the value 1 into register t0.

**A:** **`li t0, 1`** (load immediate).

---

**Q:** Write the assembly instruction that computes t2 = t0 + t1.

**A:** **`add t2, t0, t1`**

---

**Q:** Write the assembly instruction that computes t3 = t1 − t0.

**A:** **`sub t3, t1, t0`**

---

**Q:** Why do we need an infinite loop (e.g. `iloop: j iloop`) at the end of the example program?

**A:** So the processor doesn’t run past the end of our code into whatever is in memory next. The jump keeps execution at the same place and effectively “stops” the program.

---

## CPUlator and debugging

**Q:** Where will we run our Nios V programs? What do we use before the real board?

**A:** We run them on the **DE1-SoC** board (Nios V in the FPGA). **Before** using the real board, we use **CPUlator** — a web-based simulator of the DE1-SoC Nios V system.

---

**Q:** What can CPUlator emulate? Name three.

**A:** CPUlator can emulate things like the **switches**, **LEDs**, and **VGA display** on the DE1-SoC.

---

**Q:** What does the Disassembly pane in CPUlator show?

**A:** It shows the **machine code** (the numeric encoding of each instruction) and the **addresses** where instructions are stored.

---

**Q:** What debugging habit does the lecture stress? What should you do at the beginning?

**A:** **Run one instruction at a time** and see if your assumptions are correct. Always have assumptions or expectations, then check. Never assume you know what is happening until it’s proven right.

---

**Q:** The lecture says: “Do I understand what this instruction is supposed to do?” Why is that important?

**A:** So you **verify** each step. If you don’t understand what an instruction does, you can’t debug. Single-stepping and watching registers lets you confirm that each instruction does what you expect.

---

## Registers

**Q:** Which register is the “return address” (second name)? Which is the stack pointer?

**A:** **ra** (x1) is the return address. **sp** (x2) is the stack pointer.

---

**Q:** What is x0 used for?

**A:** **x0** is the **zero** register — it always holds the value **0** (read-only). It is often used for “discard” or “zero” in instructions.

---

**Q:** In the lecture example, which register holds A? Which holds B? Which holds C? Which holds D?

**A:** **A** is in **t0**, **B** in **t1**, **C** in **t2**, **D** in **t3**.

---

## True/False

**Q:** T/F: Memory stores only variables and data, not the program.

**A:** **False.** Memory also stores **the program being executed**.

---

**Q:** T/F: We use the names x0, x1, x2, … in this course for registers.

**A:** **False.** We use the **second names** (t0, t1, ra, sp, a0, s0, etc.).

---

**Q:** T/F: The processor can add two values that are only in memory, without loading them into registers first.

**A:** **False.** Operations are performed **only on registers**. Values must be loaded into registers first (then we can add, subtract, etc.).

---

End of practice. Use **L1_SUMMARY_ComputerOrg_Assembly.md** to review.
