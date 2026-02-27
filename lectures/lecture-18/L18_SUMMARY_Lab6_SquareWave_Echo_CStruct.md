# ECE 243 Lecture 18 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 6 (after Reading Week).
- **Midterm:** March 5, 6:30–8:15 pm; covers **Labs 1–6** and **Lectures 1–19**. Lecture 19 is a review. See Quercus for room, past tests, etc.
- **Last day:** Audio Part 2 — register-level control, status and data, example code.
- **Today:** **Lab 6** — square wave generator, echo box, and **using C structures** to access the audio (and parallel port) registers.

---

## 1. Recall: audio data flow (simplified)
- Flow (one channel): **Input FIFO** (samples in) → **computer** → **output FIFO** (samples out). Lab 6 Part 2: microphone → speaker. Same idea for left and right channels and the four memory-mapped registers that talk to the four FIFOs.

---

## 2. Lab 6 parts (overview)

| Part | What you do |
|------|-------------|
| **1** | Use C pointers and dereferencing for memory-mapped I/O (from Lecture 15). KEY buttons and LEDs. |
| **2** | Use code from Lecture 17 so microphone input goes to the speakers on the **real board** (CPUlator has no real mic — uses sawtooth). |
| **3** | **Square wave** generator in code; frequency set by **switches** between **100 Hz and 2000 Hz**. |
| **4** | **Echo box**: mic → speaker with **echo/delay** and **damping** (details below). |

---

## 3. Part 3: square wave
- **Square wave:** alternates between a **high** value and a **low** value: high, high, high … low, low, low … high …
- **Sample format:** 24-bit **signed** (bit 23 = sign). Use a **big negative** for low and the **largest positive** (or large positive) for high so the wave is audible.
- **Discrete samples:** The waveform is continuous in theory, but the code produces **one sample per output time step**. So you output a run of high samples, then a run of low samples, then high again, etc.
- **Sample rate:** The output D/A runs at **8 kHz** → one sample every **1/8000 s = 0.000125 s = 125 µs**. You must produce samples at that rate.
- **When to write:** Check that there is **room** in the output FIFO — use **WSRC** or **WSLC** (number of **empty** slots). If **WSRC > 0** (or WSLC > 0), you can store the next sample. (In Part 2 the input rate matches the output rate; in Part 3 you generate the wave, so you must check output space.)
- From the sample rate and desired frequency (e.g. 100–2000 Hz), you compute **how many samples** to hold high and how many low to get the right period (e.g. half-period = samples per half-cycle).

---

## 4. Part 4: echo
- **Echo:** The sound from **earlier** comes back after a **delay** and is **quieter** (damped).
- **Delay N:** “N” is how many **sample periods ago** we bring back. Lab specifies N equivalent to **0.4 seconds** (so N = 0.4 × 8000 = 3200 samples at 8 kHz).
- **Damping factor D:** 0 < D < 1. The echoed part is **multiplied by D** so it is quieter. You choose D by experiment (cannot really test echo on CPUlator without a mic).
- **Current sound:** The **current** input still goes to the output at the same time the echo is playing and fading.
- **Correct formula:**  
  **Output(t) = Input(t) + D × Output(t − N)**  
  - **Input(t)** = current mic sample (like Part 2).  
  - **Output(t − N)** = output we sent **N samples ago** — we must **store** the last N output samples in an **array**.  
  - Using **Output(t − N)** (instead of Input(t − N)) gives the “recursive” echo: that output already contained echoes from 2N, 3N, … ago, so we get a natural **infinite fade** (repeated echoes getting quieter).

---

## 5. C structures for the audio port
- Instead of raw pointers and offsets (e.g. `*(audio_ptr + 1)`), we use a **C struct** that **overlays** the memory-mapped audio registers at **AUDIO_BASE (0xFF203040)**. We **do not** allocate the struct; the hardware is already there — we only use a **pointer** to that address.
- **struct audio_t** (layout matches the hardware):
  - **control** — control/status register.
  - **rarc**, **ralc** — 8-bit: right/left **input** FIFO count (samples present).
  - **wsrc**, **wslc** — 8-bit: right/left **output** FIFO count (empty slots).
  - **ldata**, **rdata** — 32-bit (24-bit data): left/right data (read = input FIFO, write = output FIFO).
- **Pointer:** `struct audio_t * audiop = (struct audio_t *) AUDIO_BASE;`
- **Access:** `audiop->rarc`, `audiop->ldata`, `audiop->rdata`, etc. So we **name** the registers instead of using numeric offsets.
- **Pass-through loop:** `if (audiop->rarc > 0)` then `left = audiop->ldata; right = audiop->rdata; audiop->ldata = left; audiop->rdata = right;`
- **Part 3:** You should also check that there is **output space**, e.g. `audiop->wsrc > 0` (or `wslc`), before storing to the output FIFO.

---

## Quick reference
| Item | Meaning |
|------|--------|
| **Square wave (Part 3)** | High/low alternation; 24-bit signed; 8 kHz → 125 µs per sample; check WSRC/WSLC before write. |
| **Echo (Part 4)** | Output(t) = Input(t) + D × Output(t−N); N ≈ 0.4 s worth of samples; store last N outputs in array. |
| **D** | Damping factor (0 < D < 1); echo is quieter. |
| **struct audio_t** | C struct overlaying AUDIO_BASE; control, rarc, ralc, wsrc, wslc, ldata, rdata. |
| **audiop->rarc** | Use when > 0 to know there is input data; Part 3 also check wsrc/wslc for output space. |
