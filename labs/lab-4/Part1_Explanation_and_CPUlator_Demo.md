# Part 1 — Explanation + How to Demo on CPUlator

## What the code is doing (in plain words)

1. **Setup**  
   We put the KEY address in `t0` and the LED address in `t2`. We keep the “current number on the LEDs” in `s1` (1..15 or 0 for blank). We start with `s1 = 1` and show it on the LEDs.

2. **Poll loop**  
   We keep loading the KEY **Data** register (address in `t0`). That register has 4 bits: bit 0 = KEY0, bit 1 = KEY1, bit 2 = KEY2, bit 3 = KEY3. If a key is **pressed**, its bit is **1**; if **released**, bit is **0**.  
   So we do: load word → if it’s 0 (no key pressed), branch back and keep polling. When it’s non‑zero, we know at least one key is pressed.

3. **Which key?**  
   We check one bit at a time with `andi` (e.g. `andi t3, t1, 0x1` keeps only bit 0). If that bit is non‑zero we branch to `key0`, `key1`, `key2`, or `key3`.

4. **Key actions**  
   - **KEY0:** set `s1 = 1`, store to LEDs, jump to release_poll.  
   - **KEY1:** if `s1 >= 15` don’t change; else `s1 = s1 + 1`, store to LEDs, jump to release_poll.  
   - **KEY2:** if `s1 == 0` (blank) set `s1 = 1` and show it; else if `s1 <= 1` don’t change; else `s1 = s1 - 1`, store to LEDs; then jump to release_poll.  
   - **KEY3:** store 0 to LEDs (blank), set `s1 = 0`, jump to release_poll.

5. **Release poll**  
   We keep loading the KEY Data register until it’s 0 (all keys released). Then we jump back to `poll`. So we only react to the **next** press after you let go.

**Why wait for release?**  
So one physical press = one change. If we didn’t wait, we’d loop: see key still pressed → change again → see still pressed → change again … until you release.

---

## Bugs that were fixed in your original paste

1. **No initial display**  
   `s1` was never set to 1 at start, and nothing was written to the LEDs, so the LEDs could show garbage. Fix: `li s1, 1` and `sw s1, 0(t2)` at the start.

2. **KEY2 when display is 0**  
   Spec: when display is blank (0), “any other KEY” should return display to 1. Your code had `ble s1, s2, poll` with `s2 = 0`, so when `s1 = 0` you went to `poll` and did nothing. Fix: when `s1 == 0`, set `s1 = 1` and show it (e.g. `key2_set_one`), then go to release_poll.

3. **KEY2 when display is 1**  
   You should not decrement below 1. With `ble s1, s2, poll` and `s2 = 0`, when `s1 = 1` we had 1 ≤ 0 false, so we fell through and did `addi s1, s1, -1` → 0. Fix: compare to **1** (e.g. `li t4, 1` and `ble s1, t4, poll`) so we don’t decrement when already 1.

---

## How to demo on CPUlator

1. **Open CPUlator**  
   Go to cpulator.01xz.net (or your course link). Choose the **RISC-V DE1-SoC** system (or whatever your lab uses).

2. **Load the code**  
   - Copy the contents of `part1.s` into the editor (or use Load/Open if you saved the file).  
   - Make sure the file is set to **RV32** (or the correct Nios V / RISC-V variant).  
   - Assemble/Compile (e.g. F5 or the compile button). Fix any syntax errors if they appear.

3. **Run**  
   - Click **Run** (or F3).  
   - You should see the **LEDs** panel: at start, **one LED** should be on (value 1 = 0b1 = LED0 on).  
   - In the **Push buttons** panel you’ll see KEY0, KEY1, KEY2, KEY3. These are checkboxes: **checked = pressed**, **unchecked = released**.

4. **What to do step by step**  
   - **Start:** LEDs show 1 (one LED on).  
   - **KEY0:** Check KEY0 → LEDs stay 1. Uncheck KEY0 (release).  
   - **KEY1:** Check KEY1 → LEDs should show 2 (two LEDs on). Uncheck KEY1. Check KEY1 again → 3. Keep doing that until you see 15 (four LEDs: 1111). Press KEY1 again → still 15 (no change).  
   - **KEY2:** Check KEY2 → count goes down (15 → 14 → …). Release between presses. At 1, press KEY2 → still 1 (no change).  
   - **KEY3:** Check KEY3 → all LEDs off (blank = 0). Uncheck KEY3. Then check KEY0 or KEY1 or KEY2 → LEDs should go back to 1.  
   - **Corner case:** Set display to 0 (KEY3). Then press KEY2 (and release) → display should become 1 (not stay 0).

5. **Single-stepping (optional)**  
   Use **Step** (e.g. F2) to watch:  
   - `poll` loop: you’ll see `lw t1, (t0)` and `beqz t1, poll` until you “press” a key (check a box).  
   - When you check a key, `t1` becomes non‑zero, then you branch to `key0`/`key1`/`key2`/`key3`, update `s1` and `sw s1, 0(t2)`.  
   - Then you enter `release_poll` and stay there until you uncheck the key (`t1` becomes 0), then you `j poll` and wait for the next press.

6. **What you expect**  
   - One key press (checkbox on) + release (checkbox off) = **one** change on the LEDs.  
   - Display never goes above 15 or below 1 (except 0 for blank).  
   - After blank (KEY3), any other KEY brings display back to 1.

---

## Quick checklist for TA

- [ ] Start: LEDs show 1.  
- [ ] KEY0: display stays or goes to 1.  
- [ ] KEY1: increments 1→2→…→15, then stays 15.  
- [ ] KEY2: decrements down to 1, then stays 1.  
- [ ] KEY3: all LEDs off (0).  
- [ ] After KEY3, KEY0/KEY1/KEY2: display goes to 1.  
- [ ] After KEY3, KEY2: display goes to 1 (not 0).  
- [ ] We only use the KEY **Data** register (no Edge-capture).  
- [ ] We wait for key release before accepting the next press.
