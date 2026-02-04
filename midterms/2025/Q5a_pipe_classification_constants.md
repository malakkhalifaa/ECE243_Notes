# 2025 Midterm — Q5(a) [3 marks]

## Question

Setup (summary):

- Conveyor speed **1000 cm/s**; timer **100 MHz** (10⁸ Hz), counts down from **10⁹** and resets to 10⁹ at 0.
- **Class #1:** length **&gt; 100 cm** → left belt.
- **Class #2:** length **50 cm–100 cm** → stay on original belt.
- **Class #3:** length **&lt; 50 cm** → right belt.

Calculate:

1. Timer **ticks per cm** of belt movement.
2. **Minimum** timer ticks for **Class #1** (length &gt; 100 cm).
3. **Maximum** timer ticks for **Class #3** (length &lt; 50 cm).

Then define these as constants using the C macros below (fill in the right-hand sides).

```c
#define TICKS_MAX         ???   // 1B
#define TICKS_PER_SEC     ???   // 10^8
#define BELT_SPEED_CMSEC  ???   // 1000 cm/s
#define TICKS_PER_CM      ???   // from above
#define CLASS1_TICKS_MIN  ???   // min ticks for Class #1
#define CLASS3_TICKS_MAX  ???   // max ticks for Class #3
```

---

## Your answer:

_(Calculations and macro definitions.)_

---

## Detailed explanation / solution

**1. Ticks per cm**

- Timer: **10⁸** ticks per second.
- Belt: **1000** cm per second.
- Ticks per cm = (ticks/sec) / (cm/sec) = **10⁸ / 1000 = 10⁵** ticks/cm.

**2. Minimum ticks for Class #1 (length &gt; 100 cm)**

- Smallest length in Class #1 is just over **100 cm**.
- Ticks = 100 cm × 10⁵ ticks/cm = **10⁷** ticks.  
- So **CLASS1_TICKS_MIN** = **10⁷** (we use this as the threshold: **duration ≥ 10⁷** → Class #1).

**3. Maximum ticks for Class #3 (length &lt; 50 cm)**

- Largest length in Class #3 is just under **50 cm**.
- Ticks = 50 cm × 10⁵ ticks/cm = **5×10⁶** ticks.  
- So **CLASS3_TICKS_MAX** = **5×10⁶** (duration ≤ 5×10⁶ → Class #3).

**C macros:**

```c
#define TICKS_MAX         1000000000u   // 1 billion
#define TICKS_PER_SEC     100000000u    // 10^8 (100 MHz)
#define BELT_SPEED_CMSEC  1000u         // 1000 cm/s
#define TICKS_PER_CM      (TICKS_PER_SEC / BELT_SPEED_CMSEC)   // 10^5
#define CLASS1_TICKS_MIN  (100 * TICKS_PER_CM)   // 10^7
#define CLASS3_TICKS_MAX  (50 * TICKS_PER_CM)    // 5*10^6
```

**Classification logic (for part (b)):**

- **total_ticks ≥ CLASS1_TICKS_MIN** → Class #1 (send left).
- **total_ticks &gt; CLASS3_TICKS_MAX** and **total_ticks &lt; CLASS1_TICKS_MIN** → Class #2 (stay).
- **total_ticks ≤ CLASS3_TICKS_MAX** → Class #3 (send right).
