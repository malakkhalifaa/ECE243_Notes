# 2025 Midterm — Q4 [15 marks]

## Question

A Nios V assembly program is supposed to:

- Use the **interval timer** to change the **10 LEDs** on the DE1-SoC board every **0.25 seconds**.
- Display the following **LED sequence** (one line every 0.25 s), then repeat from line 1:

  - Line 1: `0b1111111111` (all 10 on)
  - Line 2: `0b1111111110`
  - Line 3: `0b1111110000`
  - Line 4: `0b1110000000`
  - Line 5: `0b0000000000`

- Interval timer: base **0xFF202000**; same register layout as in Lab 4; clock **100 MHz**.

The program below contains **5 errors** (syntax or logic). For each error, **identify the wrong line** and **give the single correct line**.

**Register layout (same as Lab 4):**  
- Offset 0: status; 4: control; 8: periodl; 0xC: periodh; etc.

---

**Program with errors (find 5 and fix):**

```asm
.global _start
.equ TIMER_BASE, 0xFF202000
.equ COUNTER_DELAY, 30000000    # ??? 
.equ LEDs, 0xff200000

_start:
    la   t5, TIMER_BASE
    sw   zero, 0(t5)
    li   t0, COUNTER_DELAY
    sw   t0, 0x8(t5)
    slli t1, t0, 16             # ???
    sw   t1, 0xc(t5)
    li   t0, 0b1100             # ???
    sw   t0, 0x4(t5)
    li   t2, 16
    la   t3, patterns
    la   t4, LEDs

tloop:
    add  t6, t3, t2
    lw   s0, (t6)
    sw   s0, (t4)
    addi t2, t2, -4
    blez t2, ploop               # ???
    li   t2, 16

ploop:
    lw   t0, 4(t5)              # ???
    andi t0, t0, 0b1
    beqz t0, ploop
    sw   zero, 0(t5)
    j    tloop

patterns:
    .word 0b1111111111, 0b1111111110, 0b1111110000, 0b1110000000, 0b0000000000
```

---

## Your answer:

1. _(wrong line and correct line)_  
2. _(wrong line and correct line)_  
3. _(wrong line and correct line)_  
4. _(wrong line and correct line)_  
5. _(wrong line and correct line)_

---

## Detailed explanation / solution

**1. COUNTER_DELAY — 0.25 s at 100 MHz**

- 0.25 s × 100,000,000 Hz = **25,000,000** counts.
- **Wrong:** `COUNTER_DELAY, 30000000`  
- **Correct:** `COUNTER_DELAY, 25000000`

**2. Period high half — must be upper 16 bits**

- Timer period is 32-bit: low 16 bits at 0x8, high 16 bits at 0xC.
- **Wrong:** `slli t1, t0, 16` (shifts left; we need the **upper** 16 bits of the 32-bit value).
- **Correct:** `srli t1, t0, 16` (shift right so upper 16 bits go into lower 16 of **t1** for storing at 0xC).

**3. Timer control — start and continuous**

- To run continuously, control is typically **CONT + ITO** (e.g. 0b0110): start bit and continuous mode.
- **Wrong:** `li t0, 0b1100`  
- **Correct:** `li t0, 0b0110` (or the exact control bits used in your lab: run + continuous).

**4. Index after last pattern — branch when index still valid**

- **t2** is used as offset: 16, 12, 8, 4, 0 for five words. After `addi t2, t2, -4`, when **t2** becomes **0** we have just used the last pattern; **next** iteration we want to go to **ploop** to wait, then **reset t2 to 16** and show first pattern again. So we want to **go to ploop when t2 &lt; 0** (all patterns done), not when **t2 ≤ 0** in the sense of “branch when t2 is 0.”  
- Actually: after processing offset 0 we do `addi t2, t2, -4` → t2 = -4. So we want “if t2 &lt; 0, go to ploop.” **blez** = branch if ≤ 0. When t2 is 0 we haven’t yet decremented; when t2 is -4 we have. So we want to **stay in tloop** while t2 ≥ 0 (still a valid index) and **go to ploop** when t2 &lt; 0. So **branch when t2 &lt; 0** → **bltz t2, ploop**. But the solution says “bgez t2, ploop” for the *wrong* line: that would mean “branch to ploop when t2 ≥ 0,” which would branch every time except when t2 &lt; 0. So the *intended* fix is: we should **not** branch to ploop when t2 is 0; we should branch to ploop only when we’ve finished all five (t2 becomes negative). So **correct:** `bltz t2, ploop` (branch if t2 &lt; 0).  
- Exam solution says: **Wrong:** `blez t2, ploop` **Correct:** `bgez t2, ploop`. That would mean: “branch to ploop if t2 ≥ 0.” Then we never take the branch when t2 = -4, so we fall through to `li t2, 16` and then… we’re not at ploop. So the loop would be: tloop, decrement t2, if t2 ≥ 0 go to ploop (wait), then … Actually re-reading: after `addi t2, t2, -4` we have t2 = 16, 12, 8, 4, 0, -4. If we **blez t2, ploop** we branch when t2 ≤ 0, so we branch when t2=0 and when t2=-4. When t2=0 we’ve just loaded the *last* pattern (offset 0); then we decrement to -4, then we branch to ploop. So we’d branch one step “late.” If we **bgez t2, ploop**: we branch when t2 ≥ 0. So after first iteration t2=12, we branch to ploop (wrong!). So that doesn’t match. The intended logic might be: “while t2 >= 0, do tloop; when t2 &lt; 0, go to ploop.” So **don’t** branch to ploop when t2 ≥ 0; branch when t2 &lt; 0. So correct is **bltz t2, ploop**. But the official solution says **bgez t2, ploop**. So they might have the order of labels reversed: maybe they want “branch to ploop when t2 ≥ 0” meaning “we still have a valid index, so go wait for timer” and “fall through when t2 &lt; 0” to reset to 16? That would be: after displaying, decrement; if t2 >= 0 (still have more or just showed one), go wait; else (t2 &lt; 0) reset to 16. So with **bgez t2, ploop**: when t2 = 16 we go to ploop (wait), then j tloop, then t2=12, ploop, etc. When t2 = 0 we showed last pattern, then addi t2,t2,-4 → t2=-4; bgez t2, ploop is false, so we fall through, li t2, 16, then we hit ploop: … no, we don’t. We have:

  tloop: ... addi t2,t2,-4; bgez t2, ploop; li t2, 16
  ploop: ...

  So after addi, if t2 >= 0 we go to ploop (wait for timer), then j tloop. If t2 < 0 we do li t2, 16 then fall through into ploop. So we reset index and then wait. So **bgez t2, ploop** gives: branch to ploop when t2 is 16,12,8,4,0 (wait after each pattern); when t2 becomes -4 we don’t branch, set t2=16, fall through to ploop. So the fix is **bgez t2, ploop** (branch when t2 ≥ 0 to go wait; when t2 &lt; 0, reset then fall through to ploop).

**5. Poll status in status register (offset 0), not control (offset 4)**

- Timer **status** (e.g. TO bit) is at **offset 0**; **control** is at offset 4.
- **Wrong:** `ploop: lw t0, 4(t5)`  
- **Correct:** `ploop: lw t0, 0(t5)` (read status to check timeout bit).

---

**Summary of the five corrections:**

| # | Wrong line | Correct line |
|---|------------|--------------|
| 1 | `.equ COUNTER_DELAY, 30000000` | `.equ COUNTER_DELAY, 25000000` |
| 2 | `slli t1, t0, 16` | `srli t1, t0, 16` |
| 3 | `li t0, 0b1100` | `li t0, 0b0110` |
| 4 | `blez t2, ploop` | `bgez t2, ploop` |
| 5 | `ploop: lw t0, 4(t5)` | `ploop: lw t0, 0(t5)` |
