# ECE 243 Lecture 17 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 5; Lab 6 after Reading Week.
- **Last day:** Audio input and output, Part 1 (A/D, D/A, FIFOs, buffering).
- **Today:** **Audio Part 2** — register-level control, sound data flow, and example code (mic to speaker).

---

## 1. Recall: data flow and FIFOs
- **Flow:** Sound → voltage (mic/amp) → **A/D** → digital samples → **input FIFO** → **computer** → **output FIFO** → **D/A** → voltage (amp) → sound.
- **Input FIFO:** Fed by the A/D; holds up to **128 samples** (DE1-SoC). If the computer doesn’t read in time, the FIFO fills and **samples are lost**.
- **Output FIFO:** Feeds the D/A. The D/A takes a **new sample every sample period** (e.g. every 100 µs). The computer must **put samples in** often enough or the output is wrong (e.g. bad sound).
- The **processor** talks **only to the input and output FIFOs** (memory-mapped), not directly to the A/D or D/A.

---

## 2. Stereo: left and right channels
- The DE1-SoC audio interface has **two channels** — **left** and **right** (stereo). There are separate input and output FIFOs for each channel.

---

## 3. Memory-mapped registers (AUDIO_BASE = 0xFF203040)
Four main addresses (offsets from base); we go through them in reverse order:

---

### (1) Leftdata and Rightdata — data registers (FIFO access)
- **Same addresses** are used for **both** input (read) and output (write); **R/W** selects which FIFO is accessed.
- **Load (read)** from **Leftdata** (e.g. `*(audio_ptr + 2)`):
  - Reads the **next sample** from the **left input FIFO** (from the A/D).
  - **Removes** that sample from the FIFO — the next load gets the **next** sample (first-in, first-out).
- **Store (write)** to **Leftdata**:
  - **Adds** a sample to the **left output FIFO** (a **different** FIFO). The D/A later **removes** it at the right time.
- Same idea for **Rightdata** (right input FIFO on read, right output FIFO on write).

---

### (2) fifospace register — how full/empty the FIFOs are
- **Read** this register to see how many slots are used or empty.
- **RALC** — number of **left input** FIFO slots **used** (of 128).
- **RARC** — number of **right input** FIFO slots **used**.
- **WSLC** — number of **left output** FIFO slots **empty**.
- **WSRC** — number of **right output** FIFO slots **empty**.
- When **input FIFOs are clear:** RALC = RARC = 0 (none occupied).
- When **output FIFOs are clear:** WSRC = WSLC = 128 (all empty).

---

### (3) Control register (write) and status (read) — address 0xFF203040
- **Same address**: **write** = control, **read** = status.
- **Control (write):**
  - **CR = 1** → **clear (empty) the input FIFOs** (left and right). Good to do at program start.
  - **CW = 1** → **clear the output FIFOs**.
- **Status (read):**
  - **RI = 1** → left/right **input** FIFO is **75% or more full** — processor should read soon (we don’t use this in the simple example).
  - **WI = 1** → **output** FIFO is **≤ 25% full** — needs more samples soon.
  - **RE** (control): if 1, **interrupt** when RI (not used in Lab 6).
  - **WE** (control): if 1, **interrupt** when WI (not used in Lab 6).

---

## 4. Lab 6 Part II: copy input to output
- **Goal:** Copy **every** input sample to the output (mic → speaker), for **both** left and right.
- **Idea:** In a loop, **read fifospace**; if there is **at least one** sample in the input (e.g. check **RARC** in the low byte), **read** left and right from the input FIFOs (Leftdata, Rightdata), then **write** those same values to the output FIFOs (same addresses, store). The **timing of the input** FIFO drives when we do work, which keeps things simpler.

---

## 5. Example code (pass-through)
- **AUDIO_BASE** = **0xFF203040**; `audio_ptr` points to the audio registers.
- **fifospace** = `*(audio_ptr + 1)` — read the fifospace register.
- **Check:** `(fifospace & 0x000000FF) > 0` — low byte is **RARC** (right input count); if > 0, there is at least one sample to read (we assume left has data too when right does).
- **Read input:** `left = *(audio_ptr + 2);` `right = *(audio_ptr + 3);` — these **remove** the samples from the input FIFOs.
- **Write output:** `*(audio_ptr + 2) = left;` `*(audio_ptr + 3) = right;` — add those samples to the output FIFOs.
- **Demo:** On real hardware, this gives mic → speaker. CPUlator cannot use a real microphone, so you may get a substitute (e.g. sawtooth). Demos: **Wilhelm Scream** or **Besame Mucho** (example .c files).

---

## 6. Lab 6 parts (overview)
- **Part 1:** Use C for simple LED/switches I/O.
- **Part 2:** Copy input sound to output (pass-through, as above).
- **Part 3:** Sound generator — **variable-frequency square wave**.
- **Part 4:** Echo box — revise Part 2 to add echo (covered next day).

---

## Quick reference
| Item | Meaning |
|------|--------|
| **Leftdata / Rightdata** | Load = read (and remove) from **input** FIFO; Store = add to **output** FIFO. |
| **fifospace** | RALC, RARC = input slots used; WSLC, WSRC = output slots empty. |
| **Control (write)** | CR=1 clear input FIFOs; CW=1 clear output FIFOs. |
| **Status (read)** | RI = input 75%+ full; WI = output ≤25% full. |
| **Pass-through** | Read fifospace; if input data, read left/right from input FIFOs, write to output FIFOs. |
| **AUDIO_BASE** | 0xFF203040. |
