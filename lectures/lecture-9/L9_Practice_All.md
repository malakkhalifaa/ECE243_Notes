# Lecture 9 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #9**.

---

## Lecture context

**Q:** What does “last day” cover in Lecture 9? What does “today” cover?

**A:** **Last day:** The stack — push and pop in assembly; how the stack is used in subroutines (saving & restoring **`ra`**); the stack is also used for many other things. **Today:** Introduction to **Memory-Mapped I/O** (connection between virtual and physical world); at the end, rules on registers for subroutines — the **Nios V / RISC-V Calling Convention**.

---

## Memory-mapped I/O

**Q:** What is memory-mapped I/O? What does it connect?

**A:** **Memory-mapped I/O** is the **connection between the virtual (internal-to-computer) world and the physical (real) world**. I/O devices (LEDs, switches, etc.) are accessed by **addresses** — we use **`lw`** and **`sw`** for both memory and I/O; the hardware uses the **address** to decide whether it’s memory or an I/O device.

---

**Q:** On the DE1-SoC board, what I/Os are available to the Nios V processor? How are they accessed?

**A:** **10 LEDs** (LEDR 9:0), **10 slider switches** (SW 9:0), **4 buttons** (KEY 3:0), **6 seven-segment displays** (SEG7 5:0). They are **accessed in software** through circuits that are part of the processor system on the FPGA — i.e. **memory-mapped I/O** (used in all processors).

---

**Q:** What address are the 10 LEDs mapped to? Which bits hold their state? Are they input or output?

**A:** **0xFF200000**. The **low-order 10 bits** hold the state (on/off) of the 10 LEDs. They are **outputs**.

---

**Q:** What address are the 10 switches mapped to? Which bits hold their state? Are they input or output?

**A:** **0xFF200040**. The **low-order 10 bits** hold the state of the 10 switches. They are **inputs**.

---

**Q:** Why can we use `lw` and `sw` for both memory and I/O? How does the hardware know what we want?

**A:** Because I/O is **memory-mapped** — each I/O device is assigned an **address**. When we do **`lw`** or **`sw`**, the processor puts the address on the address bus. The **hardware** (digital logic) uses that **address** to decide whether the access goes to **memory** or to an **I/O device** (e.g. LEDs or switches).

---

**Q:** What does `.equ LEDs, 0xFF200000` do? Why use it?

**A:** **`.equ`** sets the **symbol** (label) **LEDs** to the **number** **0xFF200000**. We use it for **ease of reading** the code (so we can write `la t0, LEDs` instead of the raw address).

---

**Q:** Write the loop that continuously copies the 10 switches into the 10 LEDs (use .equ for addresses, then la, then loop: lw from switches, sw to LEDs, j loop).

**A:**
```asm
.equ LEDs, 0xFF200000
.equ SW,  0xFF200040
_start:  la  t0, LEDs
         la  t1, SW
loop:    lw  t2, (t1)    # load switches into t2
         sw  t2, (t0)    # store into LEDs
         j   loop
```

---

## Calling convention: terminology

**Q:** What is the **caller**? What is the **callee**?

**A:** The **caller** is the code that is **calling** another subroutine. The **callee** is the subroutine that is **being called** (launched).

---

**Q:** Can the same code be both caller and callee? Give an example from the lecture.

**A:** **Yes.** **sub_1** is the **callee** when it is launched from the main program (main calls sub_1), and **sub_1** becomes the **caller** when it calls sub_2.

---

**Q:** Why do we need a “calling convention” (rules for registers and parameters)?

**A:** Different subroutines use registers differently. We must **guarantee** that code we call doesn’t **destroy** important values in our registers, or the program won’t work. So we make **rules** and everyone follows them (compilers know them; in assembly you must obey them).

---

## Calling convention: parameters and return values

**Q:** Where are the first 8 parameters passed from caller to callee? What does “a” stand for?

**A:** In registers **a0, a1, a2, a3, a4, a5, a6, a7**. The **“a”** stands for **argument** (subroutine argument).

---

**Q:** If there are more than 8 parameters, where do they go? Who is responsible for pushing and popping them?

**A:** They must be **pushed onto the stack**. The **caller** is responsible for **pushing** them before the call and **popping** them off when the callee returns.

---

**Q:** Where does the callee put the first return value (one word)? The second return value (second word)?

**A:** **First** return value: **a0**. **Second** return value: **a1**.

---

**Q:** If the callee returns more than two words, where does that information go? Who pushes it and who pops it?

**A:** The **callee** pushes the extra return values onto the stack. The **caller** pops them off after the call returns.

---

## Calling convention: caller-saved and callee-saved

**Q:** Which registers are **caller-saved** (t0–t6)? What does that mean? Who saves and restores them?

**A:** **t0–t6** are the **caller-saved** registers (“t” = **temporary**). It means the **caller** is responsible for **saving** these registers (e.g. on the stack) **before** calling a subroutine if it wants to **preserve** them for use **after** the call, and **restoring** them after the callee returns. The callee is **allowed** to change t0–t6 without saving them.

---

**Q:** Which registers are **callee-saved** (s0–s11)? What does that mean? Who saves and restores them?

**A:** **s0–s11** are the **callee-saved** registers. It means if the **callee** wants to **use** these registers, it must **save** their contents (e.g. on the stack) **before** changing them, use them, then **restore** them before returning. The **callee** takes that responsibility. If the callee doesn’t save them and changes them, CPUlator can report that you **clobbered** those registers (you can turn that check off in settings).

---

**Q:** Why are t0–t6 called “caller-saved” and s0–s11 “callee-saved”?

**A:** **Caller-saved:** the **caller** must save them if it cares about their values after the call (the callee may overwrite them). **Callee-saved:** the **callee** must save them if it uses them (so the caller’s values are preserved across the call).

---

## True/False

**Q:** T/F: Memory-mapped I/O means we use special instructions different from `lw` and `sw` to access I/O devices.

**A:** **False.** We use **the same** **`lw`** and **`sw`** for both memory and I/O. The **address** determines whether the access goes to memory or to an I/O device (memory-mapped I/O).

---

**Q:** T/F: The 10 switches on the DE1-SoC are at address 0xFF200000.

**A:** **False.** The **10 LEDs** are at **0xFF200000**. The **10 switches** are at **0xFF200040**.

---

**Q:** T/F: Parameters beyond the first 8 are pushed on the stack by the callee and popped by the caller.

**A:** **False.** **Parameters** beyond the first 8 are **pushed by the caller** and **popped by the caller** when the callee returns. (Extra **return values** beyond two words are pushed by the **callee** and popped by the **caller**.)

---

**Q:** T/F: If the callee uses t0, it must save t0 on the stack before using it and restore it before returning.

**A:** **False.** **t0–t6** are **caller-saved** — the **caller** is responsible for saving them if it needs them after the call. The **callee** may use t0–t6 without saving them.

---

**Q:** T/F: If the callee uses s0, it must save s0 on the stack before changing it and restore it before returning.

**A:** **True.** **s0–s11** are **callee-saved** — if the callee uses them, it must save their contents before changing them and restore them before returning.

---

## Multiple choice

**Q:** The LEDs on the DE1-SoC are at address: (a) 0xFF200040  (b) 0xFF200000  (c) 0x20000  (d) in a separate I/O space not accessed by address

**A:** **(b) 0xFF200000.** The switches are at 0xFF200040.

---

**Q:** The first parameter to a subroutine is passed in: (a) t0  (b) a0  (c) s0  (d) the stack

**A:** **(b) a0.** The first 8 parameters are in a0–a7.

---

**Q:** Who is responsible for saving t0 if the caller needs its value after a call? (a) The callee  (b) The caller  (c) Neither  (d) Both

**A:** **(b) The caller.** t0–t6 are caller-saved registers.

---

**Q:** Who is responsible for saving s0 if the callee uses it? (a) The callee  (b) The caller  (c) Neither  (d) Both

**A:** **(a) The callee.** s0–s11 are callee-saved registers.

---

## When do the calling-convention rules matter?

**Q:** In which labs will these calling-convention rules be enforced? Will you need to memorize them on the exam?

**A:** **Not yet in Lab 3**, but in **Labs 4 & 5**. On the **midterm and final**, the rules will be **included** (you need to **understand** them, not necessarily **memorize** them).

---

End of practice. Use **L9_SUMMARY_MemoryMappedIO_CallingConvention.md** in this folder to review.
