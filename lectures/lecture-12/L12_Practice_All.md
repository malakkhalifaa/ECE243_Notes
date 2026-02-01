# Lecture 12 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #12**.

---

## Lecture context

**Q:** What does “last day” cover in Lecture 12? What does “today” cover?

**A:** **Last day:** The Timer I/O device — how to keep track of time in a computer, **accurately**. **Today:** **Interrupt-Driven Input/Output — Part 1, Introduction**.

---

## Polling vs interrupt-driven I/O

**Q:** In Lab 4, what two things do we use **polling** to determine?

**A:** (1) **If a key pushbutton** was pressed/released (using the Data register or the Edge Capture register). (2) **If the timer** has counted down to 0 (so a specific, accurate time has passed).

---

**Q:** What is “polling” in one sentence? Why is it a problem when there are many devices?

**A:** **Polling** = repeatedly **checking** a status register in a loop (“was the button pushed? no … no … yes”) — executed **a lot**. With **many** devices (mouse, keyboard, mic, camera, screen, network, exceptions like divide by 0), polling each in turn is **very inefficient** and **impossible** to do well — so we need **interrupt-driven I/O**.

---

**Q:** What is interrupt-driven I/O? (Like the “in class” analogy.)

**A:** **Interrupt-driven I/O** = when a device **wants attention**, it **interrupts** the processor (like raising your hand in class). The processor **finishes** the current instruction, **jumps** to the **Interrupt Service Routine (ISR)** to respond, then **returns** to the interrupted program. No need to keep polling — the device “tells” the processor when something happened.

---

## How interrupts work (what happens)

**Q:** How does an input device (e.g. key pushbutton or timer) signal that it wants to interrupt the processor?

**A:** It sends a **hardware signal** — a **wire** whose value changes (e.g. 0→1 or 1→0) when the device wants to interrupt. The processor’s control logic detects this and triggers the trap sequence.

---

**Q:** When an interrupt happens at the instruction labelled * in the main program, what are the three steps (in order)?

**A:** (1) The processor **finishes** executing the instruction at *. (2) It **starts executing** the **Interrupt Request Handler** (ISR) code to “respond.” (3) It must **return** to the instruction **after** * and continue executing **as if nothing had happened** — e.g. registers used by the interrupted program must not be overwritten.

---

**Q:** Why must the interrupted program’s state (e.g. registers) be preserved? Where does the lecture say we save registers used by the handler?

**A:** So that when we **return** from the ISR, the main program continues **correctly** — nothing must disturb its execution. Registers used in the **handler** must be **saved** (and later restored) — **on the stack**.

---

## mtvec and mepc

**Q:** How does the processor know **where to jump** when an interrupt (trap) happens? What register holds that address?

**A:** The processor looks at a special **processor control register** — **`mtvec`** (machine **trap vector**). It holds the **address in memory** of the trap handler (ISR). The **code that sets up the interrupt** must **set this register**.

---

**Q:** What does **mepc** stand for? What does it hold? Why do we need it?

**A:** **mepc** = **machine exception program counter**. It holds the **PC** (program counter) of the instruction that was **interrupted** — i.e. the **return address** so we know where to go back after handling the trap. Without it we couldn’t return to the right place in the main program.

---

**Q:** What is a “trap” in Nios V / RISC-V? What are the two kinds of traps?

**A:** A **trap** is an event that causes the processor to **switch** to trap-handler code. The two kinds: **(1) Interrupt** — from I/O device, timer, etc. **(2) Exception** — e.g. divide by 0, illegal instruction, system call, “processor too hot.”

---

## Enabling interrupts

**Q:** Why must we “carefully enable” interrupts in the processor? What could go wrong if we enable them too early?

**A:** We don’t want interrupts to happen **before** we’ve set up **mtvec** (and mepc, stack, etc.). If an interrupt occurred before mtvec was set, the processor wouldn’t know where to jump and the system could crash or behave incorrectly.

---

**Q:** Besides enabling interrupts in the processor, what else must be set up? (Hint: the device.)

**A:** The **device itself** must be told that it **should send an interrupt** when something in particular happens. For example, for the KEY pushbuttons we use the **interrupt mask register** in the device’s parallel port to choose **which** of the four buttons (if any) should cause an interrupt.

---

## Processor control registers (Figure 5)

**Q:** Are the “addresses” like 0x300, 0x341 for mstatus, mepc, etc. regular memory addresses? What are they?

**A:** **No.** They are **not** regular memory addresses. Think of them as **register numbers** (control register identifiers). These registers are accessed by **special instructions** (e.g. CSR read/write), not by load/store to these numbers as if they were memory.

---

**Q:** What is **mtvec** (pseudo-address 0x305)? What does the processor use it for?

**A:** **mtvec** = **machine trap vector** register. It holds the **base address of the trap handler** (ISR). When a trap occurs, the processor **looks** at mtvec to know **which address in memory** to jump to. It also has a **mode** field (bits 2–0) for vector mode.

---

**Q:** What is **mepc** (0x341)? What does it hold?

**A:** **mepc** = **machine exception program counter**. It holds the **exception program counter** — i.e. the **PC** of the instruction that was **interrupted** (so we can return to the right place after handling the trap).

---

**Q:** What is **mcause** (0x342)? What do bit 31 and bits 30–0 tell you?

**A:** **mcause** = **cause** of the most recent trap. **Bit 31 (interrupt):** **1** = the trap was an **interrupt**; **0** = it was an **exception**. **Bits 30–0:** **exception code / IRQ** — a code that identifies **which** interrupt or exception (e.g. which device, or which exception type).

---

**Q:** What is **mie** (0x304)? What is **mip** (0x344)? How are they different?

**A:** **mie** = **machine interrupt enable** — controls **which types** of traps are **enabled** (e.g. **MTIE** bit 7 = timer interrupt enable, **MSIE** bit 3 = software interrupt enable). **mip** = **machine interrupt pending** — indicates **which** interrupts are **currently pending** (active but not yet handled), e.g. **MTIP** (bit 7), **MSIP** (bit 3). So: **mie** = “are we allowed to take this kind of interrupt?” **mip** = “did this kind of interrupt actually happen?”

---

**Q:** What is **mstatus** (0x300)? What does **MIE** (bit 3) mean?

**A:** **mstatus** = **machine status** register (privilege, global interrupt enable, etc.). **MIE** (bit 3) = **Machine Interrupt Enable** — a **global** enable for interrupts (must be on for any interrupt to be taken).

---

## True/False

**Q:** T/F: In interrupt-driven I/O, the processor stops in the middle of an instruction when an interrupt occurs.

**A:** **False.** The processor **finishes** executing the **current** instruction at the point where the interrupt is taken, then switches to the ISR. It does **not** stop in the middle of an instruction.

---

**Q:** T/F: mtvec and mepc are regular memory locations that we access with lw/sw.

**A:** **False.** They are **processor control registers** with **pseudo-addresses** (register numbers), not memory addresses. They are accessed with **special** instructions (CSR read/write), not ordinary load/store.

---

**Q:** T/F: The interrupt handler must save any registers it uses, so the interrupted program is not disturbed.

**A:** **True.** Any important state (e.g. registers) used by the interrupted program must be preserved. So the handler **saves** registers it uses (e.g. on the stack) and **restores** them before returning.

---

## Multiple choice

**Q:** When an interrupt occurs, where does the processor get the address of the ISR? (a) mepc  (b) mtvec  (c) mcause  (d) the device register

**A:** **(b) mtvec.** **mtvec** holds the **trap handler address** (where to jump). mepc holds the **return** address; mcause holds the **cause** of the trap.

---

**Q:** Which register holds the PC of the instruction that was interrupted (so we can return)? (a) mtvec  (b) mepc  (c) mcause  (d) mip

**A:** **(b) mepc.** **mepc** = machine exception program counter — it stores the **return address** (PC of interrupted instruction).

---

**Q:** Which register tells you *which* interrupt or exception occurred? (a) mtvec  (b) mepc  (c) mcause  (d) mstatus

**A:** **(c) mcause.** **mcause** holds the **cause** of the trap: bit 31 = interrupt vs exception; bits 30–0 = exception code / IRQ number.

---

End of practice. Use **L12_SUMMARY_InterruptDrivenIO_Part1.md** in this folder to review.
