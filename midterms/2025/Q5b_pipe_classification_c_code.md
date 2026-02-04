# 2025 Midterm — Q5(b) [12 marks]

## Question

Write a **C function** that uses **polling** to classify pipes by length and set the actuators as follows:

- **Sensor:** 1 bit at address **0xFF200070**, bit 0 (1 = pipe under sensor, 0 = no pipe).
- **Actuators:** same word **0xFF200070**. Write **0x10** = left, **0x100** = right, **0** = de-activate.
- Actuators are set **right after** the pipe moves past the sensor and stay active **until the next pipe** (sensor 0→1).
- You are given **`unsigned int timercount(void)`** returning the timer’s current 32-bit count (timer counts down from **TICKS_MAX** to 0 then resets).
- Timer is already running in continuous mode.

Implement the pipe classification using the constants from part (a) and handle **timer wrap** (counter resets to TICKS_MAX when it hits 0).

---

## Your answer:

_(Write your C function and any helper macros/variables below.)_

```c

```

---

## Detailed explanation / solution

**Timer wrap:**  
Elapsed ticks = **end − start** if **end ≤ start** (no wrap). If **end &gt; start** (counter wrapped), elapsed = **start + (TICKS_MAX − end)** (from start down to 0, then from TICKS_MAX down to end).

**Classification (from part (a)):**

- **total_ticks ≥ CLASS1_TICKS_MIN** → Class #1 → write **0x10** (left).
- **total_ticks ≤ CLASS3_TICKS_MAX** → Class #3 → write **0x100** (right).
- Otherwise → Class #2 → write **0** (stay; actuators already de-activated at start of each pipe).

**Typo note:** The exam solution uses **`timecount()`**; the problem states **`timercount()`**. Use **`timercount()`** as given.

**Suggested C code:**

```c
unsigned int timercount(void);   // current timer count

volatile unsigned int *dr = (unsigned int *)0xFF200070;

void pipe_classify(void) {
    unsigned int start_t, end_t, total_t;

    while (1) {
        while ((*dr & 1) == 0)   /* wait for pipe: sensor bit 0 = 1 */
            ;
        *dr = 0;                 /* de-activate actuators */
        start_t = timercount();

        while ((*dr & 1) != 0)   /* wait for pipe to leave */
            ;
        end_t = timercount();

        if (end_t > start_t)
            total_t = start_t + (TICKS_MAX - end_t);   /* wrap */
        else
            total_t = start_t - end_t;

        if (total_t >= CLASS1_TICKS_MIN)
            *dr = 0x10;          /* Class #1: left */
        else if (total_t <= CLASS3_TICKS_MAX)
            *dr = 0x100;         /* Class #3: right */
        /* else Class #2: already 0 */
    }
}
```

**Notes:**

- **Sensor** is only bit 0; use **`*dr & 1`** to read so other bits (e.g. actuator bits) don’t affect the wait loops.
- **Actuators** are set by writing **0x10** or **0x100**; writing **0** clears them. The problem says “actuators should remain active until the next pipe” — so we set 0 at “next pipe” (when sensor goes 0→1), then after measuring we set 0x10 or 0x100 (or leave 0 for Class #2).
- **CLASS1_TICKS_MIN**, **CLASS3_TICKS_MAX**, and **TICKS_MAX** are from part (a); define them (or include the header) so this code compiles.
