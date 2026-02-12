# ECE 243 Lecture #14 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 4 / Lab 5 (interrupts) next week.
- **Last day:** Nios V calling convention & Interrupts Part 2 (enabling in processor and device, CSR instructions, mcause, mie, mtvec, mepc).
- **Today:** **Code for a simple interrupt program** in Nios V / DE1-SoC — the full program that ties everything together.

---

## What the program does
- **Main program:** A loop that just sets **t0 = 1** and **t1 = 2** and jumps back (so we can check the interrupt handler doesn’t disturb them).
- **When Key 1 is pressed and released:** The KEY device signals an interrupt (IRQ18). The processor **finishes** the current instruction, saves **PC** in **mepc**, clears **MIE**, and jumps to the **interrupt handler**.
- **Interrupt handler:** Saves **t0, t1, ra** on the stack; checks **mcause** (low 31 bits) for **18** (KEYs); if so, calls **KEY_ISR**; restores t0, t1, ra; then **mret** (restore PC from mepc and turn MIE back on).
- **KEY_ISR:** Reads Edge Capture; checks Key 1 bit (0b0010); clears that edge bit by writing it back; toggles **LED 3** (read LEDs, xor bit 3, write back); **ret** to the handler.

So: **one Key 1 press → one interrupt → LED 3 flips**.

---

## Setup order (in `_start`) — do in this order
1. **Initialize stack:** `la sp, 0x20000` — handler will use the stack to save/restore registers.
2. **Disable all interrupts:** `csrw mstatus, zero` — turns off **bit 3 (MIE)** so no interrupt can fire while we configure everything.
3. **Enable interrupt from the KEY device (Key 1):**
   - `la t1, KEY_BASE`
   - `li t0, 0b0010` (bit 1 = Key 1)
   - `sw t0, 8(t1)` — **Interrupt Mask Register** (offset 8): bit i = 1 means “request interrupt when edge capture bit i goes to 1.”
   - `sw t0, 12(t1)` — **clear** Edge Capture bit for Key 1 (in case it was already set).
4. **Enable KEY interrupt in the processor:** `li t0, 0x40000` (bit 18); `csrs mie, t0` — so the processor **responds** to IRQ18 (KEYs).
5. **Set trap handler address:** `la t0, interrupt_handler`; `csrw mtvec, t0` — so when an interrupt happens, the processor knows **where to jump**.
6. **Turn on global interrupt enable (MIE):** `li t0, 0b1000`; `csrs mstatus, t0` — **after this**, interrupts can occur.

**Confusing bit:** There is both an **MIE bit** (in **mstatus**, bit 3) and an **mie** register. **mstatus.MIE** = global enable; **mie** = per-source enable (e.g. bit 18 for KEYs). Both must be on for a KEY interrupt to be taken.

---

## Main loop
- **Main_loop:** `li t0, 1`; `li t1, 2`; `j Main_loop`.
- This is the “main program” that gets interrupted. After **mret**, execution continues at the **next** instruction (e.g. the next `li` or `j`), and **t0** and **t1** must still be 1 and 2 because the handler saved and restored them.

---

## What happens when the interrupt occurs (hardware)
- Processor **finishes** the current instruction.
- **mepc** ← **PC** (address of the **next** instruction — where we’ll return).
- **MIE** (bit 3 of mstatus) ← **0** (disables further interrupts until we do **mret**).
- **PC** ← value in **mtvec** (start of **interrupt_handler**).

So the handler runs **instead** of the next instruction of the main program; when we **mret**, we go back to that next instruction and MIE is turned back on.

---

## Interrupt handler (code flow)
1. **Save registers** we’ll use: `addi sp, sp, -12`; `sw t0, 0(sp)`; `sw t1, 4(sp)`; `sw ra, 8(sp)`.
2. **Check mcause:** `csrr t1, mcause`; mask to low 31 bits (`and t1, t1, t0` with `t0 = 0x7FFFFFFF`); compare to **18** (KEYs). If not 18, jump to **end_interrupt** (don’t call KEY_ISR).
3. **Call KEY_ISR:** `call KEY_ISR` — does the Key-1-specific work (clear edge, toggle LED 3).
4. **end_interrupt:** Restore **t0, t1, ra** from stack; `addi sp, sp, 12`.
5. **mret** — return from interrupt: **PC** ← **mepc** (back to main program), and **MIE** is restored to 1 (interrupts enabled again).

---

## KEY_ISR (subroutine called by the handler)
- **la t0, KEY_BASE**; **lw t1, 12(t0)** — load **Edge Capture** register.
- **andi t1, t1, 0b0010** — keep only Key 1 bit. **bnez t1, ok_pushed** — if set, Key 1 caused the interrupt; else jump to **problem** (infinite loop).
- **ok_pushed:** **sw t1, 12(t0)** — write **0b0010** back to Edge Capture to **clear** that bit (and turn off the IRQ18 request).
- **Toggle LED 3:** **la t0, LEDs**; **lw t1, (t0)**; **xori t1, t1, 0b1000**; **sw t1, (t0)**.
- **ret** — return to the interrupt handler (which then restores and does **mret**).

---

## Lab 5 note (from lecture)
- To use **timer interrupts**, turn on the **ITO** bit (bit 0) in the **timer control register** (see Lecture 11).
- You’ll have **two** device ISRs: **KEY_ISR** (like above) and **TIMER_ISR**. The interrupt handler must **check mcause** to see which one happened (e.g. 18 for KEYs, different code for timer) and call the right ISR.

---

## Quick reference (this program)
| Step | What |
|------|------|
| **Setup** | sp; mstatus←0; KEY mask 8(t1), clear edge 12(t1); mie bit 18 (0x40000); mtvec←handler; mstatus MIE (0b1000). |
| **Main** | Loop: li t0,1; li t1,2; j Main_loop. |
| **On interrupt** | mepc←PC; MIE←0; PC←mtvec. |
| **Handler** | Save t0,t1,ra; if mcause low 31 ≠ 18 skip; else call KEY_ISR; restore; mret. |
| **KEY_ISR** | Check edge Key 1; clear edge (sw 0b0010 to 12(t0)); toggle LED 3; ret. |
| **mret** | PC←mepc; MIE←1. |
