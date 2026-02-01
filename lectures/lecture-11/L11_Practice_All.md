# Lecture 11 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #11**.

---

## Lecture context

**Q:** What does “last day” cover in Lecture 11? What does “today” cover?

**A:** **Last day:** More on I/O — Parallel Ports and the **Polling** method (KEY buttons; Data Register vs Edge Capture). Lab 4 Part 1: use **Data Register only**; Part 2: use **Edge Capture** register. **Today:** The **Timer I/O device** — how to keep track of time in a computer, **accurately**.

---

## Why hardware timers?

**Q:** Why do we need a hardware timer for “accurate” time? What’s wrong with a software delay loop?

**A:** **Software delay loops** only **approximate** time (they depend on instruction count, pipeline, etc.). **Hardware timers** use a **precise clock** (e.g. crystal oscillator) and a **counter** that counts a fixed number of clock periods, so we get **accurate** time (e.g. exactly 1 second). Lab 4 requires **precise** time measurement.

---

**Q:** What two things do we need in hardware to measure time accurately?

**A:** (1) A **clock signal** with a very **precise** frequency/period (e.g. crystal oscillator). (2) A **counter** that counts a **specific number** of those clock periods (e.g. a down counter that counts down to zero).

---

**Q:** If the timer is driven by a 100 MHz clock, what is the period of one tick? How many ticks are needed for 1 second?

**A:** **Period** = 1 / 100 MHz = **10 nanoseconds (ns)**. For **1 second** we need **100,000,000** ticks (100 million).

---

**Q:** What is a “down counter” in the context of the interval timer?

**A:** A **down counter** is loaded with a value **N** (e.g. 100,000,000) and **counts down** toward **0**. When it reaches **0**, the hardware sets the **TO (Time Out)** bit (and in continuous mode, the start value is reloaded). So “one period” = count from N down to 0.

---

## Interval timer registers

**Q:** What is the base address of the Nios V DE1-SoC interval timer? How many memory-mapped registers does it have?

**A:** **TIMER_BASE = 0xFF202000.** The interval timer has **six** memory-mapped registers (Status, Control, Counter start low, Counter start high, Counter snapshot low, Counter snapshot high).

---

**Q:** The interval timer has “16-bit registers” but we “store to them as a word.” What does that mean for a 32-bit value like 100,000,000?

**A:** Each **timer register** is only **16 bits** wide. So a **32-bit** value (e.g. 100,000,000) must be **split** into **two 16-bit chunks**: the **low 16 bits** (bits 0–15) go in the “Counter start value (low)” register, and the **high 16 bits** (bits 16–31) go in the “Counter start value (high)” register. We use **shifting** (e.g. `srli` by 16) to get the high half.

---

**Q:** What is the **Status** register? What is its offset from TIMER_BASE? What is the **TO** bit and how do you clear it?

**A:** The **Status** register is at **offset 0** (address 0xFF202000). **Bit 0** is the **TO (Time Out)** bit — it is set to **1** when the counter **reaches zero**. **Software must write 0** to this bit (e.g. store 0 to the Status register) to **clear** it after detecting a timeout, so the next countdown can be detected.

---

**Q:** What is the **Control** register? What is its offset? What value do we write to **start** the timer and run it **continuously**?

**A:** The **Control** register is at **offset 4** (0xFF202004). To **start** the timer and run it **continuously** (reload start value when countdown finishes), we write **0x6** (binary **0b0110**) — this sets **bit 1 (CONT)** = continuous mode and **bit 2 (START)** = start timer.

---

**Q:** Where do we put the **low 16 bits** of the 32-bit count-down value N? Where do we put the **high 16 bits**?

**A:** **Low 16 bits** (bits 0–15) of N → **Counter start value (low)** at **offset 0x8** (0xFF202008). **High 16 bits** (bits 16–31) of N → **Counter start value (high)** at **offset 0xC** (0xFF20200C).

---

## Using the timer (steps)

**Q:** In order, what are the four main steps to use the interval timer for a 1-second delay (then poll and repeat)?

**A:** (1) **Put N** (e.g. 100,000,000) into the Counter start value registers — low 16 bits at offset 0x8, high 16 bits at offset 0xC (use `srli` by 16 for high). (2) **Start and run continuously:** write **0x6** to the Control register (offset 4). (3) **Poll** the TO bit in the Status register (offset 0): load Status, **andi** with 0x1, **beqz** back until TO = 1. (4) **Clear** the TO bit by writing 0 to the Status register; then repeat (e.g. toggle LED and go back to step 3).

---

**Q:** Why must we **clear** the TO bit after detecting a timeout? What happens if we don’t?

**A:** The TO bit **stays 1** until software clears it. If we don’t clear it, the next time we poll we would still see TO = 1 and think another timeout happened. Clearing it (write 0) **resets** it for the **next** countdown cycle.

---

**Q:** How do we split a 32-bit value in register `t0` into low 16 bits and high 16 bits for the timer? Give the idea (store low, then get high, then store high).

**A:** **Store low:** `sw t0, 0x8(t5)` — the store of a 32-bit word will put the low 16 bits into the timer’s low register (the timer only uses 16 bits of the word). **Get high:** `srli t1, t0, 16` — shift right by 16 so bits 16–31 move to bits 0–15 in t1. **Store high:** `sw t1, 0xc(t5)`.

---

## True/False

**Q:** T/F: A software delay loop gives exactly 1 second on the DE1-SoC.

**A:** **False.** Software delay loops only **approximate** time; they are not precise. A **hardware timer** with a 100 MHz clock and a count of 100,000,000 gives **accurate** 1-second intervals.

---

**Q:** T/F: The TO bit in the Status register is set to 1 by hardware when the counter reaches zero, and is cleared by software writing 0.

**A:** **True.** Hardware sets TO = 1 on timeout; software must write 0 to the Status register to clear TO for the next cycle.

---

**Q:** T/F: Writing 0x6 to the Control register only starts the timer once; when the countdown finishes, the timer stops.

**A:** **False.** **0x6** sets **CONT** (continuous) and **START**. In **continuous** mode, when the countdown finishes, the start value is **reloaded** and the timer keeps counting — it does **not** stop.

---

**Q:** T/F: The Counter start value is a single 32-bit register at offset 0x8.

**A:** **False.** The timer has **16-bit** registers. The 32-bit start value is split: **low** 16 bits at **offset 0x8**, **high** 16 bits at **offset 0xC**.

---

## Multiple choice

**Q:** The interval timer base address on the DE1-SoC is: (a) 0xFF200000  (b) 0xFF200050  (c) 0xFF202000  (d) 0x20000

**A:** **(c) 0xFF202000.** 0xFF200000 is LEDs; 0xFF200050 is KEY.

---

**Q:** For a 100 MHz clock, how many ticks in 1 second? (a) 1,000,000  (b) 10,000,000  (c) 100,000,000  (d) 1,000,000,000

**A:** **(c) 100,000,000.** 100 MHz = 100 million cycles per second.

---

**Q:** To start the timer and run it continuously, we write ___ to the Control register. (a) 0x1  (b) 0x2  (c) 0x4  (d) 0x6

**A:** **(d) 0x6.** 0x6 = 0b0110 = **CONT** (bit 1) + **START** (bit 2).

---

**Q:** The TO (Time Out) bit is in the ___ register at offset ___. (a) Control, 4  (b) Status, 0  (c) Counter start low, 8  (d) Counter start high, 0xC

**A:** **(b) Status, 0.** The Status register is at offset 0; bit 0 is TO.

---

## Code / offsets

**Q:** Write the instruction to **clear** the TO bit, assuming `t5` holds TIMER_BASE.

**A:** **`sw zero, 0(t5)`** — store 0 to the Status register (offset 0).

---

**Q:** Write the instruction to write the **Control** register (start + continuous) with value 0x6, assuming `t5` = TIMER_BASE and `t0` = 0x6.

**A:** **`sw t0, 4(t5)`** — Control register is at offset 4.

---

**Q:** After loading the 32-bit delay value into `t0`, we store the low 16 bits to the timer. What instruction? Then we need the high 16 bits in another register. What instruction? Then store the high 16 bits. What instruction? (Assume `t5` = TIMER_BASE.)

**A:** **Store low:** `sw t0, 0x8(t5)`. **Get high:** `srli t1, t0, 16`. **Store high:** `sw t1, 0xc(t5)`.

---

**Q:** In the polling loop for the timer, we load the Status register, then mask to keep only the TO bit (bit 0). What instructions? (Assume `t5` = TIMER_BASE, result in `t0`.)

**A:** **`lw t0, 0(t5)`** — load Status register. **`andi t0, t0, 0b1`** (or **`andi t0, t0, 1`**) — keep only bit 0 (TO). Then **`beqz t0, ploop`** to branch back if TO is 0.

---

End of practice. Use **L11_SUMMARY_HardwareTimer.md** and the example `.s` file in this folder to review.
