# Lab 4 — Rubric Checklist

Use this to make sure you hit every rubric item before your TA demo.

---

## Part 1 — Basic polling (Part 1) is functional

| Level | What the TA looks for |
|-------|------------------------|
| **Not working / multiple bugs / violating spec** | Using Edge-capture in Part 1, or logic broken. |
| **Works but corner case bug** | e.g. display starts at 0 instead of 1, or KEY2 when blank doesn’t return to 1, or you can decrement below 1. |
| **Fully correct** | Data register only, wait for release, KEY0→1, KEY1→inc (max 15), KEY2→dec (min 1), KEY3→blank, “any other KEY” returns to 1, no corner cases. |

**Check:** Part 1 uses **only** the KEY **Data** register (offset 0), **not** Edge-capture. You wait for key **release** after each action. Display starts at **1**; when blank (0), KEY0/KEY1/KEY2 set it back to **1**; you never go above 15 or below 1.

---

## Part 2 — Binary counter with delay loops is functional

| Level | What the TA looks for |
|-------|------------------------|
| **Not working / multiple bugs** | Counter or stop/start broken, wrong register. |
| **Works but corner case or delay far off 0.25 s** | e.g. delay way too fast/slow, or one edge case wrong. |
| **Fully correct, timing approximately right** | Counter 0–255, step ~every 0.25 s, stop/start on any KEY via Edge-capture, delay value reasonable for board. |

**Check:** You use a **delay loop** (e.g. load a big number, decrement until 0). You use **Edge-capture** (offset 0x0C) for KEY so you don’t miss a press during the delay. You clear edge bits by storing **1**. COUNTER_DELAY: **10,000,000** on board (or **25,000,000** if you want closer to 0.25 s), **500,000** in CPUlator.

---

## Part 3 — Binary counter with hardware timer is functional

| Level | What the TA looks for |
|-------|------------------------|
| **Not working / multiple bugs** | Timer not used, wrong addresses, or counter/stop-start broken. |
| **Works but corner case** | Small bug in wrap or stop/start. |
| **Fully correct** | Same behaviour as Part 2 but **exact** 0.25 s from hardware timer; poll TO, clear TO, period = 25,000,000. |

**Check:** Timer base **0xFF202000**, period **25,000,000** (0.25 s at 100 MHz). You poll **Status (offset 0)** for TO, clear TO by writing 0, use **Control (offset 4)** = 0x6 (START + CONT). Counter 0–255, stop/start on any KEY (Edge-capture).

---

## Part 4 — Real time (sec:hundredths) on LEDs in binary

| Level | What the TA looks for |
|-------|------------------------|
| **Not working / multiple bugs** | Wrong encoding, wrong wrap, or timer/KEY broken. |
| **Works but corner case** | e.g. wrap at 7.99 wrong, or one bit wrong. |
| **Fully correct** | Seconds (0–7) on LEDR9:7, hundredths (0–99) on LEDR6:0, one timer for 0.01 s, wrap 7.99→0.00, stop/run on any KEY. |

**Check:** One timer for **0.01 s** (1,000,000 ticks). Display = (seconds << 7) | hundredths. When seconds reach 8 or hundredths reach 100, wrap correctly to 0.00.

---

## Comments

| Level | What the TA looks for |
|-------|------------------------|
| **Few or no comments** | Almost no explanation. |
| **Limited comments** | Some comments but structure/state not explained. |
| **Well commented** | Structure and important state/variables explained **throughout**. Subroutine **inputs, outputs, and functionality** commented. |

**Check:** Every file has a short header (what the program does, which registers/addresses matter). Main loops and KEY/timer logic have brief comments. **Every subroutine** has a comment saying what it does, what it uses (inputs), and what it returns (outputs). Important variables (e.g. “s2 = counter”, “s3 = run/stop”) are noted.

---

## Appropriate use of subroutines

| Level | What the TA looks for |
|-------|------------------------|
| **No subroutines** | Everything in one big main loop. |
| **Only one subroutine (across all 4 parts) or calling convention not respected** | e.g. only Part 3 has a subroutine, or you don’t save/restore callee-saved regs or ra. |
| **Code broken into re-usable pieces; RISC-V calling convention used** | At least Parts 2, 3, (and 4) use subroutines (e.g. delay, wait_timer, wait_001_sec). Callee saves s0–s11 and ra when needed; caller saves t0–t6 if needed after a call. |

**Check:** Part 2: e.g. **do_delay** subroutine, saves/restores **ra** and **s0**. Part 3: e.g. **wait_timer_quarter**, saves/restores **ra** and **s4**. Part 4: e.g. **wait_001_sec**, saves/restores **ra** and **s4**. No subroutines required in Part 1 (rubric is across all 4 parts).

---

## Lab performance (question answering) /4

| Level | What the TA looks for |
|-------|------------------------|
| **Incorrect or no answer** | Wrong or can’t explain. |
| **Mostly correct but incomplete/unclear/minor errors** | Right idea but fuzzy or small mistakes. |
| **Clear and organized; shows understanding** | You explain your code and the course material (polling, Data vs Edge-capture, timer, calling convention) clearly. |

**Check:** Use **Lab4_TA_Review_Polling_IO_CallingConvention.md** to practice: polling, Data vs Edge-capture, why wait for release, why Edge-capture in Part 2, timer registers, caller vs callee, caller-saved vs callee-saved, parameters/return, call/ret, LIFO.

---

## Quick checklist before demo

- [ ] Part 1: Data register only, wait for release, all KEY rules and corner cases (start at 1, blank→1 on KEY0/1/2, max 15, min 1).
- [ ] Part 2: Delay loop, Edge-capture for stop/start, clear edge by storing 1, timing ~0.25 s.
- [ ] Part 3: Hardware timer 25,000,000, poll TO, clear TO, same behaviour as Part 2.
- [ ] Part 4: Sec on LEDR9:7, hundredths on LEDR6:0, 0.01 s timer, wrap 7.99→0.00, stop/run on KEY.
- [ ] Comments: Header + structure + state/variables + subroutine inputs/outputs/functionality in each file.
- [ ] Subroutines: Parts 2, 3, 4 use subroutines; RISC-V calling convention (save/restore ra and callee-saved regs).
- [ ] Can explain: polling, Data vs Edge-capture, timer, calling convention (use TA review sheet).

Total: **/10** (each teammate graded on their own demo + answers).
