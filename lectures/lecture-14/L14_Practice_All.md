# Lecture 14 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #14** (code for a simple interrupt program).

---

## Lecture context

**Q:** What does Lecture 14 cover? What does the example program do when Key 1 is pressed?

**A:** Lecture 14 covers the **full code** for a simple interrupt program on Nios V / DE1-SoC. The example program: main loop sets t0=1, t1=2; when **Key 1** is pressed and released, an interrupt runs the handler, which calls **KEY_ISR** to **toggle LED 3**. So one Key 1 press → one interrupt → LED 3 flips.

---

## Setup order

**Q:** In what order should we do the setup steps in `_start`? Why is “disable interrupts” done first?

**A:** (1) Initialize stack (`la sp, 0x20000`). (2) Disable interrupts (`csrw mstatus, zero`). (3) Enable KEY device interrupt for Key 1 (mask at offset 8, clear edge at 12). (4) Enable KEY in processor (mie bit 18). (5) Set mtvec to interrupt_handler. (6) Enable global MIE (mstatus bit 3). We **disable interrupts first** so no interrupt can fire before mtvec, stack, and device are configured — otherwise the processor might jump to a wrong or uninitialized handler.

---

**Q:** What does `sw t0, 8(t1)` do in the KEY setup? What does `sw t0, 12(t1)` do? (Assume t1 = KEY_BASE and t0 = 0b0010 for Key 1.)

**A:** **8(t1):** Writes to the **Interrupt Mask Register** (KEY_BASE + 8). Setting bit 1 to 1 means “when **edge capture** bit 1 goes to 1, **request** an interrupt on IRQ18.” **12(t1):** Writes to the **Edge Capture** register (KEY_BASE + 12). Writing 1 to bit 1 **clears** that edge bit (so we start with no pending KEY interrupt).

---

**Q:** Why do we use **0x40000** when enabling KEY interrupts in the processor? Which register do we set with it?

**A:** **0x40000** has **bit 18** set (1 << 18). KEY pushbuttons use **IRQ18**, so we set **bit 18 of mie** with **csrs mie, t0** (t0 = 0x40000). That tells the processor to **take** KEY interrupts when they are requested.

---

**Q:** What is the difference between **mstatus (MIE bit 3)** and **mie (bit 18)**? Do we need both for a KEY interrupt to be taken?

**A:** **mstatus.MIE** (bit 3) = **global** interrupt enable — if 0, no interrupt is taken. **mie** bit 18 = **per-source** enable for IRQ18 (KEYs). **Both** must be 1: global on (mstatus) and KEY source on (mie) for a KEY interrupt to be taken.

---

## Main loop and hardware behavior

**Q:** What does the main loop in the lecture program do? Why is it written that way?

**A:** It does **li t0, 1**; **li t1, 2**; **j Main_loop**. It’s written so we can **check** that after an interrupt and **mret**, t0 and t1 are still 1 and 2 — i.e. the handler saved and restored them correctly.

---

**Q:** When an interrupt occurs, what does the **hardware** do to **PC**, **mepc**, and **MIE** before jumping to the handler?

**A:** **mepc** ← **PC** (address of the next instruction — where we’ll return). **MIE** (bit 3 of mstatus) ← **0** (interrupts disabled during the handler). **PC** ← value in **mtvec** (first instruction of the interrupt handler).

---

## Interrupt handler

**Q:** Which registers does the interrupt handler save on the stack, and why those?

**A:** It saves **t0**, **t1**, and **ra**. The handler **uses** t0 and t1 (e.g. for mcause check and as scratch), and it **calls** KEY_ISR so **ra** is overwritten by **call**. Saving them ensures the **main program** still sees t0=1, t1=2 after **mret**, and the handler can return to the right place after KEY_ISR.

---

**Q:** Why do we check **mcause** (low 31 bits) for **18** before calling KEY_ISR?

**A:** **mcause** tells us **which** interrupt or exception occurred. **18** is the code for **KEY** (IRQ18) on the DE1-SoC. If we didn’t check, we might call KEY_ISR when the interrupt was from the **timer** or something else, which would be wrong. So we only call KEY_ISR when mcause (masked to 31 bits) equals 18.

---

**Q:** What does **mret** do? Why do we use it instead of **ret** to leave the handler?

**A:** **mret** (1) sets **PC** ← **mepc** (so we return to the instruction after the one that was interrupted) and (2) **restores MIE** to 1 (re-enables interrupts). We use **mret** because we entered via an **interrupt** (hardware set mepc and turned off MIE). **ret** only does **pc ← ra** and doesn’t touch MIE or mepc, so it’s wrong for exiting the interrupt handler.

---

## KEY_ISR

**Q:** In KEY_ISR, why do we **read** the Edge Capture register and **andi** with 0b0010 before doing anything?

**A:** To **confirm** that **Key 1** (bit 1 = 0b0010) caused the interrupt. In a program with only Key 1 enabled it’s redundant, but it’s good practice; if the bit isn’t set we branch to an error/halt path instead of clearing or toggling wrongly.

---

**Q:** How do we **clear** the Key 1 edge capture bit? Why must we clear it?

**A:** **Write 1** to that bit in the Edge Capture register: e.g. **sw t1, 12(t0)** where t1 = 0b0010 and t0 = KEY_BASE (offset 12 = Edge Capture). Clearing it **turns off** the interrupt request on IRQ18 and lets us detect the **next** Key 1 press/release.

---

**Q:** How do we **toggle** LED 3 in KEY_ISR? (One sentence for load, one for flip, one for store.)

**A:** **Load** the LED word from the LEDs base address. **Flip** bit 3 with **xori** and 0b1000. **Store** the result back to the LEDs base address.

---

**Q:** KEY_ISR ends with **ret**. Where does execution go after that **ret**?

**A:** Back to the **interrupt handler** (the instruction after **call KEY_ISR**). The handler then restores t0, t1, ra from the stack and executes **mret** to return to the main program.

---

## Lab 5 (timer interrupts)

**Q:** For Lab 5 timer interrupts, what extra bit do we turn on in the timer hardware? What does it do?

**A:** We turn on the **ITO** (Interrupt Time-Out) bit — **bit 0** of the timer **control** register. When the timer reaches zero and ITO is 1, the timer **requests** an interrupt (on its IRQ line), similar to how the KEY device requests on IRQ18 when edge capture is set.

---

**Q:** If we have both KEY and timer interrupts, how does the interrupt handler know which ISR to call?

**A:** We **read mcause** and mask to the low 31 bits. One value (e.g. **18**) means KEY → call **KEY_ISR**. Another value (timer’s IRQ code) means timer → call **TIMER_ISR**. So one handler, two branches based on **mcause**.

---

## True/False

**Q:** T/F: We should set **mtvec** before enabling global MIE so that if an interrupt occurs, the processor knows where to jump.

**A:** **True.** If MIE were on before mtvec was set, an interrupt could be taken with an invalid or old value in mtvec and the processor could jump to the wrong place.

---

**Q:** T/F: The interrupt handler must use **ret** to return to the main program.

**A:** **False.** The handler must use **mret**. **ret** only does pc ← ra and does not restore **mepc** into PC or turn MIE back on.

---

**Q:** T/F: In the simple Key-1–LED-3 program, the main loop does useful work (e.g. updates LEDs) in addition to waiting for interrupts.

**A:** **False.** In the lecture example the main loop only sets t0 and t1 and jumps back; it’s there to show that the handler doesn’t disturb main’s registers. All “useful” work on Key 1 (toggle LED 3) is done in **KEY_ISR**.

---

## Quick code-order check

**Q:** Which comes first in setup: enabling KEY interrupt in **mie**, or setting **mtvec**?

**A:** **mie** (KEY bit 18) comes **before** **mtvec** in the lecture order. So: device mask + edge clear → **csrs mie, t0** (0x40000) → **csrw mtvec, t0** (handler address) → **csrs mstatus, t0** (MIE). (You could set mtvec before mie and still be safe as long as MIE is off until the very end.)

---

End of practice. Use **L14_SUMMARY_SimpleInterruptCode.md** and the example code (e.g. in lecture-13 folder) to review.
