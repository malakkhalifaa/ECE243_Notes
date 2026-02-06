# ECE 243 Lab 4 — Memory Mapped I/O, Polling and Timers

**Due:** During your scheduled lab period (week of February 2, 2026).  
**Submit to Quercus:** `part1.s`, `part2.s`, `part3.s`, `part4.s`  
**Grading:** In-person with your TA on the DE1-SoC board.

---

## Part I — `part1.s`

- **Display** a binary number (1..15 or 0=blank) on the **10 LEDs** (0xFF200000).
- **KEY0:** set display to **1** (binary 0000000001).
- **KEY1:** **increment** (max **15** = 1111).
- **KEY2:** **decrement** (min **1**); if display is **0** (blank), KEY2 returns display to **1**.
- **KEY3:** **blank** display (0); pressing KEY0/KEY1/KEY2 after that returns display to **1**.
- Use **polling** on the **Data register only** (KEY base 0xFF200050, offset 0). **Do not use** Interrupt-mask or Edge-capture.
- After each button press, **wait until the button is released**.
- Uses subroutines: `wait_for_any_key`, `wait_for_release`.

---

## Part II — `part2.s`

- **Binary counter** 0..255 on the 10 LEDs, incremented **approximately every 0.25 s** using a **delay loop**.
- When counter reaches **255**, wrap to **0**.
- **Stop/start** when **any** KEY is pressed (toggle run/stop).
- Use **Edge-capture** (KEY offset 0x0C) so button presses are not missed during the delay. Clear edge bits by **storing 1** into each bit.
- **COUNTER_DELAY:** use **10,000,000** for the DE1-SoC board; use **500,000** for CPUlator (change the `.equ` at top of file).
- Subroutine: `do_delay` (callee saves s0).

---

## Part III — `part3.s`

- Same behaviour as Part II (counter 0..255, stop/start on any KEY, Edge-capture).
- Use the **hardware timer** (base 0xFF202000) for an **exact** 0.25 s delay instead of a delay loop.
- Timer: 100 MHz; 0.25 s = **25,000,000** ticks. Set Counter start (low 0x8, high 0xC), Control (0x4) = CONT + START (0x6), poll **TO** in Status (offset 0), clear TO by writing 0.

---

## Part IV — `part4.s`

- **Binary clock** on the 10 LEDs:
  - **Seconds (0..7)** on **LEDR9:7** (high 3 bits).
  - **Hundredths of a second (0..99)** on **LEDR6:0** (low 7 bits).
- Use **one** timer to measure **0.01 s** (10 ms = 1,000,000 ticks at 100 MHz). Poll TO; on each TO: increment hundredths; if hundredths ≥ 100 then hundredths=0 and seconds++; if seconds ≥ 8 then seconds=0.
- When clock reaches **7.99 s**, wrap to **0.00 s**.
- **Stop/run** on any KEY (Edge-capture).

---

## Addresses (from handout / DE1-SoC figures)

| Device        | Address      | Notes |
|---------------|-------------|--------|
| LEDs          | 0xFF200000  | Bits 0–9 = LEDR0–LEDR9 |
| KEY (pushbtn) | 0xFF200050  | Data offset 0; Edge-capture offset 0x0C |
| Interval Timer| 0xFF202000  | Status 0; Control 4; Period low 0x8; high 0xC |

---

## Build and run

1. Program the DE1-SoC with the Nios V system (Monitor Program or course method).
2. Assemble and load the appropriate `.s` file. Entry point is **`_start`**.
3. For CPUlator (Part II): set `COUNTER_DELAY` to **500000** in `part2.s`.

---

## Files

| File     | Description |
|----------|-------------|
| `part1.s` | Part I: KEY-controlled binary display (1..15, blank). Data reg only. |
| `part2.s` | Part II: 0.25 s delay-loop counter; Edge-capture stop/start. |
| `part3.s` | Part III: Same as Part II with hardware timer. |
| `part4.s` | Part IV: Binary clock (sec + hundredths), wrap 7.99→0. |
