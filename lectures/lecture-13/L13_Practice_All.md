# Lecture 13 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #13**.

---

## Lecture context

**Q:** What does “last day” cover in Lecture 13? What does “today” cover?

**A:** **Last day:** Introduction to Interrupt-Driven Input/Output. **Today:** **Interrupts Part 2 — more detail** (CSR instructions, IRQ lines, KEY interrupt setup, full interrupt-driven program outline, calling convention reminder).

---

## Recall the story of interrupts

**Q:** When an interrupt happens at instruction \* in the main program, what are the three steps (in order)?

**A:** (1) The processor **finishes** executing instruction \*. (2) It **starts executing** the **Interrupt Request Handler** (ISR) code. (3) Once the ISR is finished, it must **return** to the **instruction after \*** and continue with **no registers disturbed**.

---

**Q:** Why must “no registers be disturbed” when we return from the ISR?

**A:** So the **main program** continues **correctly** — as if the interrupt never happened. If the handler overwrote registers the main program was using, the main program would see wrong values and fail.

---

## Summary of Lecture 12 (five points)

**Q:** How does the processor know **where to go** when an interrupt happens? Who sets that?

**A:** The processor looks at the **mtvec** (machine trap vector) register for the **address** of the trap handler (ISR). The **interrupt set-up code** must **set mtvec** (e.g. with **csrw mtvec, t0** where t0 holds the handler address).

---

**Q:** How does the processor know **where to return** after the ISR? What register holds that?

**A:** The processor stores the **PC** of the interrupted instruction in **mepc** (machine exception program counter). When we do **mret**, the processor copies **mepc** into **PC** so we return to the right place.

---

**Q:** Where does the handler save registers it uses? Why?

**A:** **On the stack.** So the interrupted program’s state is preserved — the handler must save any registers it will use, then restore them before **mret**.

---

**Q:** Why must we “carefully enable” interrupts in the processor? What could go wrong if we enable them too early?

**A:** We don’t want an interrupt to occur **before** we’ve set **mtvec**, stack, device mask, etc. If an interrupt happened before mtvec was set, the processor wouldn’t know where to jump and could crash or behave incorrectly.

---

**Q:** Besides enabling interrupts in the processor, what must we do for the **device** (e.g. KEY pushbuttons)?

**A:** The **device** must be told **when** to send an interrupt. For the KEY pushbuttons we use the **Interrupt Mask Register** (KEY_BASE + offset 8) — set **bit i** to 1 so that **Key i** (when its edge capture bit goes to 1) **requests** an interrupt.

---

## CSR instructions

**Q:** What does **csrr rd, csr** do? What does **csrw csr, rs1** do?

**A:** **csrr rd, csr** — **read** the control/status register **csr** into **rd** (destination register). **csrw csr, rs1** — **write** the value in **rs1** into the CSR.

---

**Q:** Write the two instructions to put the address of **interrupt_handler** into **mtvec** (use **t0**).

**A:** **`la t0, interrupt_handler`** then **`csrw mtvec, t0`**.

---

**Q:** What do **csrs** and **csrc** do? When would we use them?

**A:** **csrs csr, rs1** — **set** (to 1) the bits in the CSR where **rs1** has 1. **csrc csr, rs1** — **clear** (to 0) the bits in the CSR where **rs1** has 1. We use them to **enable** or **disable** specific interrupt bits (e.g. set bit 18 of **mie** for KEYs, set bit 3 of **mstatus** for global MIE) without overwriting other bits.

---

**Q:** To **turn on** bit 3 of **mstatus** (the MIE bit) without changing other bits, what instruction would we use? (Assume we have put 0b1000 into **t0**.)

**A:** **`csrs mstatus, t0`** — this **sets** bit 3 (and any other bits where t0 has 1) in mstatus. So MIE (bit 3) is turned on; other bits are unchanged.

---

## IRQ lines and MIE

**Q:** What is an IRQ line? What does the **MIE** register have to do with it?

**A:** Each interrupt **cause** (e.g. KEY buttons, timer) is assigned an **interrupt request line** — **IRQi**. The **corresponding bit** of the **MIE** (Machine Interrupt Enable) register must be **set to 1** to **enable** that type of interrupt. So MIE is a per-source enable mask.

---

**Q:** On the Nios V DE1-SoC, which IRQ line do the KEY pushbuttons use? What value do we use to set that bit in **mie**?

**A:** The KEY pushbuttons use **IRQ18**. So we must set **bit 18** of **mie** to 1. **0x40000** has bit 18 set (1 << 18 = 0x40000). So we do **`li t0, 0x40000`** then **`csrs mie, t0`**.

---

## KEY parallel port and interrupts

**Q:** To have **Key i** edge capture **cause an interrupt**, what must we do in the KEY device? Which register (offset from KEY_BASE)?

**A:** We must **turn on** the **Interrupt Mask Register** bit for Key i. The Interrupt Mask Register is at **KEY_BASE + offset 8**. Set **bit i** to 1 so that when **edge capture bit i** goes to 1, the device **requests** an interrupt (on IRQ18).

---

**Q:** When we **service** the KEY interrupt (inside the handler), why must we **clear** the edge capture bit for that key? What happens if we don’t?

**A:** Clearing the edge capture bit (by **writing 1** to that bit in the Edge Capture Register at offset 12) **turns off** the interrupt request on IRQ18. If we don’t clear it, the bit stays 1 and the device may keep requesting interrupts (or we might not detect the **next** press/release correctly).

---

## Interrupt handler and mret

**Q:** What does **mret** do? (Two things from the lecture.)

**A:** **mret** (return from interrupt/trap): (1) It **copies mepc into PC** — so execution continues at the instruction that was interrupted (or the one after it, depending on convention). (2) It **restores the MIE bit** (e.g. back to 1) so **interrupts are re-enabled**.

---

**Q:** When an interrupt occurs, what does the processor do to the MIE bit in mstatus? Why?

**A:** The processor **sets MIE to 0** (disables further interrupts) when it takes the interrupt. So the handler runs with **interrupts disabled** until we do **mret**, which prevents **nested** interrupts from disturbing the handler before it has saved state.

---

**Q:** How do we check **which** device caused the interrupt (e.g. KEYs vs timer)? Which register and which part of it?

**A:** We **read mcause** with **csrr**. The **low 31 bits** (exception/IRQ code) tell us **which** interrupt or exception. For the KEY pushbuttons on the DE1-SoC, the code is **18**. So we mask mcause to 31 bits and compare to 18; if equal, we call the KEY ISR.

---

## Calling convention (reminder)

**Q:** Which registers hold the first 8 parameters (caller → callee)? Which hold the first one or two return values?

**A:** **First 8 parameters:** **a0–a7**. **First return value:** **a0**. **Second return value:** **a1**.

---

**Q:** Who is responsible for saving **t0–t6** if they are needed after a call? Who is responsible for saving **s0–s11** if the callee uses them?

**A:** **t0–t6** are **caller-saved** — the **caller** is responsible for saving them (on the stack) before the call and restoring them after the callee returns. **s0–s11** are **callee-saved** — the **callee** is responsible for saving them (on the stack) before using them and restoring them before returning.

---

**Q:** When are these calling convention rules enforced? Do you need to memorize them for the exam?

**A:** They are **enforced in Labs 4 & 5**. On the **midterm and final**, the rules will be **included** (e.g. on the reference sheet); you need to **understand** them, not necessarily **memorize** them.

---

## True/False

**Q:** T/F: **csrw mtvec, t0** writes the value in **t0** into the **mtvec** register so the processor knows where to jump on an interrupt.

**A:** **True.** **csrw** writes the source register (rs1 = t0) into the CSR (mtvec). So the trap handler address is set.

---

**Q:** T/F: To enable KEY interrupts we set bit 18 of **mstatus**.

**A:** **False.** We set **bit 18** of **mie** (Machine Interrupt Enable for specific sources). We set **bit 3** of **mstatus** (MIE = global machine interrupt enable) to allow **any** enabled interrupt to be taken.

---

**Q:** T/F: The interrupt handler must clear the edge capture bit for the key that caused the interrupt so that the interrupt request is turned off.

**A:** **True.** Clearing that bit (by writing 1 to it in the Edge Capture Register) turns off the related interrupt request on IRQ18.

---

## Multiple choice

**Q:** To read **mcause** into **t1**, we use: (a) lw t1, mcause  (b) csrr t1, mcause  (c) csrw mcause, t1  (d) csrs mcause, t1

**A:** **(b) csrr t1, mcause.** **csrr** is the CSR **read** instruction (destination, then CSR).

---

**Q:** KEY pushbuttons on the DE1-SoC use IRQ: (a) 0  (b) 3  (c) 18  (d) 31

**A:** **(c) 18.** So we set **bit 18** of **mie** (e.g. 0x40000) to enable KEY interrupts.

---

**Q:** **mret** does which of the following? (a) Pops the return address from the stack  (b) Copies **mepc** into **PC** and re-enables MIE  (c) Clears **mcause**  (d) Jumps to **mtvec**

**A:** **(b)** **mret** copies **mepc** into **PC** (so we return to the interrupted instruction) and **restores MIE** (re-enables interrupts).

---

End of practice. Use **L13_SUMMARY_Interrupts_Part2.md** and the example `.s` file in this folder to review.
