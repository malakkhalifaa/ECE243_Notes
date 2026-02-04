# 2025 Midterm — Q1(d) [2 marks]

## Question

What is **CPUlator**? Also, name **one thing** that CPUlator **cannot** do that the DE1-SoC Computer System hardware can do.

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

**What is CPUlator:**

- **CPUlator** is a **simulation** of the DE1-SoC hardware that runs on a regular computer (e.g. in a **web browser**).
- It **compiles/assembles** programs for the Nios V processor and **simulates** the execution of the program inside that simulated “other” computer.
- So you can write and run Nios V assembly (and C) without having the physical board in front of you.

**One thing CPUlator cannot do that the DE1-SoC hardware can do:**

- **Take input from a microphone** (as in Lab 6) — the real board has physical I/O; the simulator does not have a real microphone.
- **Or:** CPUlator **cannot run as fast** as the real hardware — it is a software simulation, so it is slower than the actual FPGA and processor.
- **Or:** Other physical I/O or real-time behaviour that the simulator does not model (e.g. exact timing, real sensors/actuators).

**Summary:** CPUlator = **simulator** of the DE1-SoC (Nios V) system in a browser; it compiles/assembles and runs your code. One limitation: e.g. no real microphone input (Lab 6), or it cannot match the real hardware’s speed.
