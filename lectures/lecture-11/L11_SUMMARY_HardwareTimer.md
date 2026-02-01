# ECE 243 Lecture #11 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 3 / Lab 4.
- **Last day:** More on I/O — Parallel Ports and the **Polling** method of synchronization; KEY buttons parallel port (Data Register vs Edge Capture). Lab 4 Part 1: use **Data Register only** to trigger an action; Part 2: use **Edge Capture** register.
- **Today:** The **Timer I/O device** — how to keep track of time in a computer, **accurately**.

---

## Why hardware timers? Software delay vs accurate time
- **Lab 4** asks you to write code that **precisely** measures time and uses it.
- **Lab 3 and 4** also use a **software delay loop** that only **approximates** time (software delay loops have many reasons why they are only approximate).
- **Accurate** time in hardware: need a **precise clock** (e.g. crystal oscillator) and a **counter** that counts a specific number of clock periods.

---

## How accurate time is measured in hardware
1. **Clock signal** with a very precise frequency/period — e.g. a **crystal oscillator**.
2. **Counter** — count a specific number of those clock periods.

**Example:** A **100 MHz** clock → period = **10 nanoseconds (ns)**.
- **How many ticks for 1 second?** **100,000,000** (100 million).
- The timer uses a **down counter**: you **load** it with a value (e.g. 100,000,000), and it **counts down** toward **0**. When it reaches **0**, one second has passed (with zero-detect logic).

The Nios V DE1-SoC has an **interval timer** with **six memory-mapped registers** that connect software to this circuit. The timer registers are **16 bits each**, but you **store to them as a word** (32-bit); so a 32-bit value must be **split into two 16-bit chunks** (low and high).

---

## Nios V DE1-SoC Interval Timer — registers (base 0xFF202000)

| Address       | Register                    | Bits / meaning |
|---------------|-----------------------------|----------------|
| **0xFF202000**| **Status Register**         | Bit 0 **(TO)**: Time Out — set to **1** when counter reaches zero; **software must write 0** to clear it. Bit 1 (RUN): timer running. Bits 2–31: unused. |
| **0xFF202004**| **Control Register**        | Bit 0 (ITO): Interrupt Timeout. Bit 1 **(CONT)**: Continuous mode (reload start value when countdown finishes). Bit 2 **(START)**: Start timer. Bit 3 (STOP): Stop timer. Bits 4–31: unused. **Write 0x6 (0b0110)** = CONT + START → start and run continuously. |
| **0xFF202008**| **Counter start value (low)**  | Bits **0–15** of the 32-bit count-down value N. (Timer has 16-bit registers; only low 16 bits of this word are used.) |
| **0xFF20200C**| **Counter start value (high)** | Bits **16–31** of the 32-bit count-down value N. |
| **0xFF202010**| **Counter snapshot (low)**   | Read current count — lower 16 bits. |
| **0xFF202014**| **Counter snapshot (high)**  | Read current count — upper 16 bits. |

- **TO (Time Out):** When the down counter reaches **zero**, the hardware sets the **TO** bit in the Status register to **1**. Software **polls** this bit; after detecting a timeout, software **clears** it by **writing 0** to the Status register (or to the TO bit).
- **Continuous mode (CONT):** When the countdown finishes, the start value is **reloaded** into the counter with no cycles lost, so the timer keeps repeating.

---

## How to use the interval timer (four steps)

**1. Put the count-down value N into the Counter start value registers.**  
- **N** = number of clock ticks (e.g. **100,000,000** for 1 second at 100 MHz).  
- **Low 16 bits** (bits 0–15) of N → store at **offset 0x8** from timer base (Counter start value low).  
- **High 16 bits** (bits 16–31) of N → store at **offset 0xC** (Counter start value high).  
- Use **shifting** to split: e.g. store N in low; then **`srli t1, t0, 16`** to get high 16 bits, store in high.

**2. Turn on START and CONT in the Control register.**  
- **Write 0x6** (binary **0b0110**) to the Control register at **offset 0x4**.  
- This **starts** the timer (loads start value, enables countdown) and sets **continuous** mode (reload when it reaches zero).

**3. Poll the TO bit in the Status register.**  
- **Load** the Status register (offset **0** from base).  
- **`andi`** with **0b1** (or 0x1) to keep only the **TO** bit (bit 0).  
- **`beqz`** back to the load if TO is 0 — keep polling until TO becomes 1 (countdown reached zero).

**4. Clear the TO bit.**  
- Once you detect TO = 1, **write 0** to the Status register (offset 0) so the TO bit is reset for the **next** countdown cycle.  
- Then you can repeat (e.g. toggle LED and go back to step 3).

---

## Example: 1-second timer, toggle LED 0 each time
- **TIMER_BASE** = 0xFF202000, **COUNTER_DELAY** = 100000000 (1 s at 100 MHz), **LEDs** = 0xFF200000.  
- Clear TO: `sw zero, 0(t5)`.  
- Load N = 100000000 into t0; `sw t0, 0x8(t5)` (low); `srli t1, t0, 16`; `sw t1, 0xc(t5)` (high).  
- Start + continuous: `li t0, 0b0110`; `sw t0, 4(t5)`.  
- Loop: store LED value to LEDs; **xori** to flip bit for next time; **poll**: `lw t0, (t5)`, `andi t0, t0, 0b1`, `beqz t0, ploop`; then `sw zero, (t5)` to clear TO; jump back to top of loop.

---

## Quick reference

| Item | Meaning |
|------|---------|
| **TIMER_BASE** | **0xFF202000** — base address of interval timer. |
| **100 MHz, 1 second** | **100,000,000** ticks. |
| **Down counter** | Load value N, count down to 0; zero-detect sets **TO** bit. |
| **Status (offset 0)** | Bit 0 = **TO** (Time Out). **Write 0** to clear TO. |
| **Control (offset 4)** | **0x6 (0b0110)** = **CONT** + **START** — start and run continuously. |
| **Start value low (offset 0x8)** | Bits 0–15 of N. |
| **Start value high (offset 0xC)** | Bits 16–31 of N (e.g. `srli` by 16). |
| **16-bit registers** | Timer has 16-bit registers; 32-bit value split into low and high. |
| **Poll TO** | Load Status → **andi** with 0x1 → **beqz** back until TO = 1 → then clear TO. |
