# ECE 243 Lecture #13 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 4 / Lab 5 next week.
- **Last day:** Introduction to Interrupt-Driven Input/Output.
- **Today:** **Interrupts Part 2 — more detail**.

---

## Recall the story of interrupts
- **Need:** Synchronize external devices/signals with the software running on the processor. Call the program running on the processor the **main program**.
- **When someone pushes and releases a Key** (that you want to cause an interrupt), we think of it happening at instruction **\***.
- **Then:**
  1. The processor **finishes** executing instruction \*.
  2. It **starts executing** the **Interrupt Request Handler** (ISR) code.
  3. Once the ISR is finished, it must **return** to continue with the **instruction after \*** with **no registers disturbed**.

---

## Summary of Lecture 12 (key points)
1. **Where to go when interrupt happens?** — **mtvec** (machine trap vector). Processor looks here for the **address** of the trap handler (ISR). Your **interrupt set-up code** sets **mtvec**.
2. **Where to return?** — **mepc** (machine exception program counter). Processor stores the **PC** of the interrupted instruction here so we can return after the ISR.
3. **Preserve state** — Any important state (e.g. registers used in the handler) must be **saved** — **on the stack**, by the handler code — and restored before returning.
4. **Enable interrupts in the processor** — Must be done **carefully**, after everything is set up (e.g. mtvec, stack). Don’t want interrupts before setup is complete.
5. **Device must be told to send an interrupt** — e.g. for KEY pushbuttons, you set which of the four keys should cause an interrupt (using the **Interrupt Mask Register** in the KEY parallel port).

---

## CSR instructions (Control/Status Register)
- **csr** = one of the processor control registers (e.g. **mtvec**, **mstatus**, **mie**, **mepc**, **mcause**). **rd** = destination register (x0–x31). **rs1** = source register.
- **Read:** **`csrr rd, csr`** — read the CSR into **rd**.
- **Write:** **`csrw csr, rs1`** — write **rs1** into the CSR. **`csrwi csr, uimm`** — write unsigned immediate into CSR.
- **Set bits:** **`csrs csr, rs1`** — set bits in CSR where **rs1** has 1. **`csrsi csr, uimm`** — set bits by immediate.
- **Clear bits:** **`csrc csr, rs1`** — clear bits in CSR where **rs1** has 1. **`csrci csr, uimm`** — clear bits by immediate.

**Example — put interrupt handler address into mtvec:**
```asm
la   t0, interrupt_handler
csrw mtvec, t0
interrupt_handler: ...
```

---

## IRQ lines and MIE
- Each possible **cause** of an interrupt (e.g. KEY buttons, timer) is assigned its own **interrupt request line** — **IRQi** (from DE1-SoC manual, e.g. page 11).
- The **corresponding bit** of the **MIE** (Machine Interrupt Enable) register must be **set to 1** to **enable** that specific type of interrupt.
- **KEY pushbuttons** on the DE1-SoC use **IRQ18** — so we must set **bit 18** of **mie** to 1 (e.g. **0x40000** = bit 18 set) using **`csrs mie, t0`** with **t0 = 0x40000**.

---

## KEY parallel port and interrupts
- To have **edge capture** for Key i **cause an interrupt**, we must **turn on** the **Interrupt Mask Register** bit for Key i (KEY_BASE + offset **8**). Bit i = 1 means “cause an interrupt when edge capture bit i goes to 1.” This tells the **device** when to **request** an interrupt on wire **IRQ18**.
- When **servicing** the interrupt, we must **turn off** (clear) the **edge capture bit** for that key — by **writing 1** to that bit in the Edge Capture Register (KEY_BASE + offset **12**). This **turns off** the related interrupt request (on IRQ18) so we don’t get repeated interrupts until the next press/release.

---

## Interrupt-driven program (outline)
**Setup (in _start):**
1. **Initialize stack:** `la sp, 0x20000`.
2. **Disable processor interrupts** while setting up: `csrw mstatus, zero` (turns off bit 3 = MIE).
3. **Enable interrupts from KEY device:** Load KEY_BASE; set Interrupt Mask Register (offset 8) so Key i causes interrupt; clear Edge Capture (offset 12) for that key.
4. **Enable KEY interrupt in processor:** Set **bit 18** of **mie** (e.g. `li t0, 0x40000`; `csrs mie, t0`).
5. **Set mtvec:** `la t0, interrupt_handler`; `csrw mtvec, t0`.
6. **Enable processor interrupts (MIE):** Set **bit 3** of **mstatus** (e.g. `li t0, 0b1000`; `csrs mstatus, t0`).
7. **Main loop:** Do main program work (e.g. set t0, t1, jump back).

**Interrupt handler:**
- Upon interrupt, **MIE** is automatically **set to 0** (further interrupts disabled until we return).
- **Save** registers the handler will use (e.g. t0, t1, ra) on the **stack** (`addi sp, sp, -12`; `sw t0, 0(sp)`; `sw t1, 4(sp)`; `sw ra, 8(sp)`).
- **Check mcause:** Read **mcause** with **`csrr`**; mask to low 31 bits (to get exception/IRQ code). For KEYs, code is **18**. If not 18, skip to restore and return.
- **Call device-specific ISR** (e.g. KEY_ISR).
- **Restore** registers from stack; **`addi sp, sp, 12`**.
- **`mret`** — return from interrupt: copies **mepc** into **PC** (so we return to instruction after \*) and **restores MIE** to 1 (re-enables interrupts).

**KEY_ISR (e.g. for Key 1, toggle LED 3):**
- Load Edge Capture Register (offset 12); **andi** with **0b0010** (Key 1). If not set, branch to error/halt.
- **Clear** edge capture bit for Key 1 by **storing 0b0010** (write 1 to that bit) to Edge Capture Register.
- Read LEDs; **xori** bit 3 to flip LED 3; store back.
- **`ret`** (return to interrupt handler, which then restores and does **mret**).

---

## Calling Convention (Nios V / RISC-V) — reminder
- **Parameters (caller → callee):** First **8** in **a0–a7**. More than 8 → **caller** pushes on stack and pops after return.
- **Return values (callee → caller):** **1 word** in **a0**, **2 words** in **a0, a1**. More → **callee** pushes on stack; **caller** pops.
- **t0–t6 (caller-saved):** **Caller** saves/restores if it needs them after a call.
- **s0–s11 (callee-saved):** **Callee** saves/restores if it uses them (on the stack). CPUlator can report “clobbered” if you don’t.
- **Enforced:** Labs 4 & 5. On midterm/final: understand them, not necessarily memorize.

---

## Quick reference
| Item | Meaning |
|------|---------|
| **csrr rd, csr** | Read CSR into **rd**. |
| **csrw csr, rs1** | Write **rs1** into CSR. |
| **csrs / csrc** | Set / clear bits in CSR (by register or immediate). |
| **mtvec** | Trap handler address; set with **csrw mtvec, t0**. |
| **mie bit 18** | Enable KEY interrupts (0x40000); use **csrs mie, t0**. |
| **mstatus bit 3 (MIE)** | Global machine interrupt enable; **csrs mstatus, t0** with t0=0b1000 to enable. |
| **KEY Interrupt Mask** | KEY_BASE + 8; bit i = 1 → Key i edge capture causes interrupt. |
| **Clear edge capture** | Write 1 to that bit in Edge Capture (KEY_BASE + 12) when servicing. |
| **mret** | Return from interrupt: PC ← mepc, re-enable MIE. |
| **mcause** | Low 31 bits = exception/IRQ code (e.g. 18 for KEYs). |
