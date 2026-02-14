# ECE 243 Lecture #2 — Summary Sheet

## Lecture context
- **Work-in-flight:** Find a lab partner (or wait until lab to be assigned); do Lab 1 prep for next week. Flag 1-on-1 help and Alan AI coming soon.
- **Last day:** Computer organization and assembly; assembly instructions and machine code (numbers); CPUlator as a simulator; example program and a bit of debugging.
- **Today:** Lab 1, and **loops and conditional branches** in Nios V assembly.

---

## 1. Lab 1 overview (next week)

| Part | What you do |
|------|-------------|
| **I** | Think about how you work with a partner; discuss styles; be ready to tell your TA your collaboration plan. |
| **II** | Learn CPUlator: panes, single-stepping, breakpoints, full execution. |
| **III** | Write a simple program (sum 1 to 30 in a loop). |
| **IV** | Read “Using GDB with Nios V UofT” up to section 2.5; do it in lab. |
| **V** | Run the Part III program on the **real hardware** (DE1-SoC). |

- **Grading:** TA grades in lab — questions on prep (including team/Part I), code, and showing it works on hardware. You must show you can do specific things and understand them (see lab rubric).
- **Submission:** Hand in code to Quercus (both partners) by end of lab. This is the record of your work. Both partners must do and understand all parts; collaboration between partners is allowed.

---

## 2. Two computers (Lab 1 / GDB)

- **CPUlator:** Everything runs in your browser on one machine.
- **Real lab:** Two physical systems:
  1. **Windows 10 computer** — you run the **assembler** (assembly → machine code) and **GDB** here.
  2. **DE1-SoC** — the Nios V system (processor + memory + I/O) is **programmed into the FPGA** (e.g. via `gmake`). You **download** the machine code into the **memory of the Nios V computer**. Then **GDB on the Windows machine** tells the **Nios V** to run the program.

So: assemble on Windows → download code to Nios V memory → GDB (on Windows) controls execution on the DE1-SoC. Real engineers use hardware because that is what we build; reality can differ from simulation.

---

## 3. Loops and the first program (Part III)

- **Task:** Compute the **sum of the numbers from 1 to 30** in a loop.
- To build a loop you need a **conditional branch**: jump back to the start of the loop only if a condition is true; otherwise exit the loop.

---

## 4. Unconditional jump (review)

- **`j iloop`** — jump to the instruction at label **iloop** (e.g. `iloop: j iloop` gives an infinite loop).
- **Labels** (e.g. `iloop`, `myloop`, `fin`) name an instruction so we can refer to it; the **assembler** turns labels into addresses. We don’t have to track numerical addresses ourselves.

---

## 5. Conditional branch

- A **conditional branch** either:
  - **Jumps** to a **label** if the condition is **true**, or
  - **Falls through** to the **next** instruction if the condition is **false**.
- **General form:**  
  **`bXX rA, rB, DEST_LABEL`**  
  where **rA** and **rB** are registers being compared, **XX** is the condition, and **DEST_LABEL** is where to go if the condition is true.

---

## 6. Branch conditions (Nios V / RISC-V)

| Instruction | Condition (go to label if …) |
|-------------|------------------------------|
| **beq** rA, rB, LABEL | rA **==** rB |
| **bne** rA, rB, LABEL | rA **!=** rB |
| **bge** rA, rB, LABEL | rA **>=** rB (signed) |
| **bgeu** rA, rB, LABEL | rA **>=** rB (unsigned) |
| **blt** rA, rB, LABEL | rA **<** rB (signed) |
| **bgt** rA, rB, LABEL | rA **>** rB (signed) |

- **Signed vs unsigned:** For **ge**, **le**, **gt**, **lt** you can add **`u`** for **unsigned** (e.g. **bgeu**, **bltu**). **You** decide whether the 32 bits are interpreted as signed or unsigned; there are no “types” in assembly — it’s in the mind of the programmer (unlike C where you declare `int` vs `unsigned`).

---

## 7. Example: count from 1 to 4 in a loop

- **C idea:** `for (i = 1; i <= 4; i++) { }` — we test the condition **at the end** of the loop in assembly.

```asm
.global _start
_start:
    li   t0, 1          # t0 <- 1  (counter i)
    li   t1, 4          # t1 <- 4  (upper bound)
myloop:
    addi t0, t0, 1     # t0 <- t0 + 1  ("add immediate")
    ble  t0, t1, myloop # if t0 <= t1, go to myloop; else next instruction
fin:
    j    fin           # infinite loop (stop)
```

- **`addi t0, t0, 1`** — “add immediate”: add the constant 1 to t0.
- **`ble t0, t1, myloop`** — if **t0 ≤ t1** (signed), go to **myloop**; otherwise fall through to `fin`.

---

## 8. CPUlator demo (lecture)

- Watch the **program counter (pc)** — it holds the address of the **next** instruction to run.
- Use **single-step** to execute one instruction at a time.
- Use **breakpoints** to stop at a label or address.
- Use **run** (full execution) to run until a breakpoint or the end.

---

## 9. Next: memory organization

- The lecture leads into **memory organization** in the Nios V processor (covered in later lectures).

---

## Quick reference

| Item | Meaning |
|------|--------|
| **j LABEL** | Unconditional jump to LABEL. |
| **bXX rA, rB, LABEL** | Conditional branch: if condition XX is true, go to LABEL; else next instruction. |
| **beq / bne** | Equal / not equal. |
| **bge / blt / bgt** | Signed ≥ / < / >; add **u** for unsigned. |
| **addi rd, rs1, imm** | rd ← rs1 + immediate (e.g. add 1 for increment). |
| **Labels** | Names for instructions; assembler resolves addresses. |
| **Signed vs unsigned** | Programmer’s choice; use branch with or without **u**. |
