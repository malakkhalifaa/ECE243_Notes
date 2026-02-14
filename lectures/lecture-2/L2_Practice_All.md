# Lecture 2 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #2**.

---

## Lecture context

**Q:** What does “last day” cover? What does “today” cover?

**A:** **Last day:** Introduction to computer organization and assembly; assembly instructions and machine code; CPUlator; example program and debugging. **Today:** Lab 1, and **loops and conditional branches** in Nios V assembly.

---

**Q:** What are the five parts of Lab 1 (briefly)?

**A:** **I** — Partner and collaboration plan. **II** — Learn CPUlator (panes, single-step, breakpoints, full run). **III** — Write a simple program (sum 1 to 30 in a loop). **IV** — Read GDB doc up to 2.5 and do it in lab. **V** — Run the program on the real DE1-SoC hardware.

---

## Lab 1 and two computers

**Q:** How is the real lab setup different from CPUlator in terms of where things run?

**A:** CPUlator runs **everything in your browser** on one machine. In the real lab there are **two physical systems**: the **Windows 10 computer** (where you run the assembler and GDB) and the **DE1-SoC** (where the Nios V program runs after you download code into its memory).

**Q:** On which machine do you run the assembler? On which machine does the Nios V program execute?

**A:** The **assembler** runs on the **Windows 10** machine. The **Nios V program** runs on the **DE1-SoC** (after the machine code is downloaded into the Nios V computer’s memory).

**Q:** Why does the lecture say “real engineers use hardware, not simulators”?

**A:** Because we **actually build** hardware; testing on the real board is the true test. **Reality can differ from simulation**, so we must verify on the DE1-SoC.

---

## Loops and branches

**Q:** What assembly program are you asked to write in Lab 1 Part III?

**A:** A program that **computes the sum of the numbers from 1 to 30** in a loop.

**Q:** What instruction do you need to build a loop (instead of an infinite jump)?

**A:** A **conditional branch**: jump back to the start of the loop only **if** a condition is true; otherwise fall through and exit the loop.

**Q:** What is a label? Who keeps track of the numerical address of the instruction at that label?

**A:** A **label** is a name we put on an assembly instruction so we can refer to it (e.g. in a jump or branch). The **assembler** keeps track of the numerical address; we don’t have to.

**Q:** What does `j iloop` do? What does `iloop: j iloop` do?

**A:** **`j iloop`** jumps to the instruction at label **iloop**. **`iloop: j iloop`** is an infinite loop: the only instruction executed is “jump to iloop,” so the processor keeps executing that same jump forever.

---

## Conditional branch

**Q:** In one sentence, what does a conditional branch do when the condition is true? When it is false?

**A:** If the condition is **true**, the next instruction executed is the one at **DEST_LABEL**. If the condition is **false**, execution continues with the **next** instruction after the branch.

**Q:** What is the general form of a conditional branch? What do rA, rB, and DEST_LABEL represent?

**A:** **`bXX rA, rB, DEST_LABEL`**. **rA** and **rB** are the two registers being compared. **XX** is the condition (eq, ne, ge, lt, etc.). **DEST_LABEL** is the label to jump to if the condition is true.

**Q:** What does **beq** rA, rB, LABEL do? What does **bne** do?

**A:** **beq:** go to LABEL if **rA == rB**. **bne:** go to LABEL if **rA != rB**.

**Q:** What does **ble** rA, rB, LABEL do? Is it signed or unsigned?

**A:** **ble** means “branch if less than or equal.” Go to LABEL if **rA ≤ rB** using **signed** comparison.

**Q:** How do you get an **unsigned** “greater than or equal” branch? What does the **u** mean?

**A:** Use **bgeu** rA, rB, LABEL. The **u** means the comparison is **unsigned** (the 32 bits are interpreted as a non‑negative integer).

**Q:** Who decides whether the bits in a register are treated as signed or unsigned in assembly?

**A:** The **programmer** decides. There are no types in assembly — only bits. You choose signed or unsigned by using branch instructions with or without the **u** suffix.

---

## Example program (count 1 to 4)

**Q:** In the count-1-to-4 program, what is in **t0**? What is in **t1**?

**A:** **t0** is the **counter** (i), starting at 1 and then incremented. **t1** holds the **upper bound** (4).

**Q:** What does **addi t0, t0, 1** do?

**A:** **“Add immediate.”** It does **t0 ← t0 + 1** (adds the constant 1 to t0).

**Q:** What does **ble t0, t1, myloop** do in words?

**A:** If **t0 ≤ t1** (signed), go to the instruction at label **myloop**; otherwise, go to the next instruction (and thus exit the loop).

**Q:** In the C loop `for (i = 1; i <= 4; i++) { }`, does the lecture do the condition check at the start or the end of the loop in assembly?

**A:** At the **end** of the loop. We increment, then branch back if the condition is still true.

---

## CPUlator

**Q:** What does the program counter (pc) show in CPUlator?

**A:** The **address of the next instruction** that will be executed (before that instruction runs).

**Q:** What are breakpoints for?

**A:** So execution **stops** when the pc reaches a chosen instruction (label or address). You can then inspect registers and memory or single-step from there.

---

## True/False

**Q:** T/F: In the lab, the assembler runs on the DE1-SoC board.

**A:** **False.** The assembler runs on the **Windows 10** machine. The DE1-SoC runs the **downloaded** program.

**Q:** T/F: **blt** uses unsigned comparison.

**A:** **False.** **blt** is **signed** “less than.” For unsigned, use **bltu**.

**Q:** T/F: In assembly, the type “signed” or “unsigned” is declared in the program like in C.

**A:** **False.** In assembly there are no such declarations. The **programmer** decides by choosing **bge** vs **bgeu**, etc. — it’s “in the mind of the programmer.”

---

End of practice. Use **L2_SUMMARY_Loops_ConditionalBranches.md** to review.
