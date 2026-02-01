# ECE 243 Lecture #12 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 4 Prep.
- **Last day:** The Timer I/O device — how to keep track of time in a computer, **accurately**.
- **Today:** **Interrupt-Driven Input/Output — Part 1, Introduction**.

---

## The story so far: Polling (Lab 4)
In Lab 4 you use **polling** to determine:
1. **If a key pushbutton** was pressed/released (Data register or Edge Capture register).
2. **If the timer** has counted down to 0 (so a specific, accurate time has passed).

**Polling** = a kind of **mindless loop**: “was the button pushed? no … no … yes” — executed **a lot**.

**Problems with polling:**
- What if you need to **poll 2 devices** at the same time?
- **Very inefficient**, and **impossible** when there are **many** devices/things to synchronize: mouse, keyboard, microphone, camera, screen, internet packets, and exceptional issues (divide by 0, address out of range, high temperature warning).
- So rather than polling each status register in turn (“did this happen? did that happen? …”), we need a better synchronization mechanism that is **fundamental to all computers**: **Interrupt-Driven I/O**.

---

## Interrupt-Driven I/O (idea)
- **Like in class:** you **interrupt** me when you have a question (I was “teaching blah blah”; you interrupt; I answer; then continue). The same thing happens in the computer, but must **never fail** (huge number of interrupts worldwide every second) so it is **orchestrated carefully**.

**One way to think about it:**
- Each **input device** (e.g. key pushbuttons or timer) sends a **hardware signal** (a wire whose value changes 0→1 or 1→0) when it **wants to interrupt** what the processor is doing.
- We assume the computer was doing some **useful task** in a loop but can be **interrupted** to deal with an outside event (e.g. key push). The processor normally fetches instructions from memory, executes them, often fetches the next in order unless there is a jump/branch.
- When someone **pushes and releases Key 0** (and the system is set so that causes an interrupt), the interrupt happens at **one of several possible instructions** in that loop — e.g. at the instruction labelled **\***.

**What happens (under control of the processor’s finite state machine):**
1. The processor **finishes** executing the instruction at address **\***.
2. It **starts executing** the **Interrupt Request Handler** (ISR) code to “respond.”
3. It then must **return** to the instruction **after \*** and continue executing **as if nothing had happened** — e.g. the registers the interrupted program was using must not be overwritten; nothing must disturb the correct execution of the interrupted program.

---

## How the processor knows where to go: mtvec
- **How does the processor know which address to jump to** when the interrupt happens?
- **Nios V answer:** There is a special **processor control register**, **`mtvec`** (machine **trap vector**), where the processor **looks** to get the **address in memory** it should go to (the trap handler / ISR).
- The **code that sets up the interrupt** must **set this register**.
- An **interrupt** is one kind of **trap** in the Nios V / RISC-V world. The **other** kind of trap is an **exception** (e.g. divide by 0, illegal instruction, system call, “processor too hot”).

---

## Where to return: mepc
- The processor must **remember where to return** in the main program after the trap/interrupt/exception is handled.
- In Nios V there is a special **processor register** reserved for this: **`mepc`** (machine **exception program counter**). It stores the **PC** of the instruction that was interrupted (so we can return to the instruction **after** that one, or to that one, depending on convention).

---

## Preserving state (registers)
- **Rule:** Any **important state** of the processor that was being used in the **interrupted program** must be **preserved** by the interrupt service handler.
- For example: **registers** used in the handler must be **saved** — **where?** On the **stack**. (And restored before returning.)

---

## Enabling interrupts
- Interrupts must be **carefully enabled** within the processor — we don’t want interrupts to happen before we’ve set **mtvec** (and mepc, etc.) correctly.
- The **device itself** (e.g. pushbuttons) also needs to be told that it **should send an interrupt** when something in particular happens — e.g. which of the four KEY buttons should cause an interrupt, using the **interrupt mask register** in the device’s parallel port.

---

## Nios V / RISC-V processor control registers (Figure 5)
**Important:** The “addresses” below (e.g. 0x300, 0x341) are **not regular memory addresses** — think of them as **register numbers** (control registers are accessed by special instructions, not by load/store to these numbers as memory).

| Pseudo-address | Register | Purpose / key bits |
|----------------|----------|---------------------|
| **0x300** | **mstatus** | Machine status. **MIE** (bit 3): Machine Interrupt Enable. **MPP** (bits 11–12): Machine Privilege. |
| **0x301** | **misa** | Which RISC-V architecture is supported. |
| **0x304** | **mie** | **Enable** for **specific types** of traps (interrupts/exceptions). **MTIE** (bit 7): Machine Timer Interrupt Enable. **MSIE** (bit 3): Machine Software Interrupt Enable. |
| **0x305** | **mtvec** | **Trap handler address** — base address of the ISR (where to jump when a trap occurs). **Mode** (bits 2–0): vector mode for trap handling. |
| **0x341** | **mepc** | **Exception Program Counter** — stores the **PC** of the instruction that was interrupted (return address). |
| **0x342** | **mcause** | **Cause** of the most recent trap. **Bit 31 (interrupt):** 1 = interrupt, 0 = exception. **Bits 30–0:** exception code / IRQ number (which interrupt or exception). |
| **0x343** | **mtval** | Exception-specific information (e.g. address of bad instruction). |
| **0x344** | **mip** | Which interrupts are **pending** (active but not yet handled). **MTIP** (bit 7): Machine Timer Interrupt Pending. **MSIP** (bit 3): Machine Software Interrupt Pending. |

- More on **enabling/disabling** interrupts (using these registers) in the next lecture.
- These control registers are only accessible when the processor is in a **privileged/trusted** mode. In our labs, your code is always treated as trusted. In normal computers (laptop, phone, etc.), this privilege is only for the **operating system**, not user programs — you’ll see this in an Operating Systems course.

---

## Quick reference
| Item | Meaning |
|------|---------|
| **Polling** | Repeatedly check a status register in a loop; inefficient with many devices. |
| **Interrupt-driven I/O** | Device sends a **hardware signal** when it wants attention; processor **finishes** current instruction, jumps to **ISR**, then **returns** to interrupted program. |
| **Trap** | Umbrella term: **interrupt** (from I/O, timer, etc.) or **exception** (e.g. divide by 0, illegal instruction, system call). |
| **mtvec** | **Trap vector** — processor looks here for the **address** of the trap handler (ISR). Must be set by setup code. |
| **mepc** | **Exception PC** — holds the **PC** of the interrupted instruction (so we can return). |
| **Preserve state** | Handler must **save** (e.g. on stack) any registers it uses so the interrupted program is not disturbed. |
| **Enable interrupts** | Must set up **mtvec** (and later **mie**, etc.) before enabling; each **device** has an interrupt mask to choose when it sends an interrupt. |
