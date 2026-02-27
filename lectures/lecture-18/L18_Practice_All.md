# Lecture 18 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture 18**.

---

## Lecture context

**Q:** What does “today” cover in Lecture 18?

**A:** **Lab 6** — building a **square wave** (Part 3) and an **echo** (Part 4), and using **C structures** as a clean way to access the audio (and parallel port) registers.

---

**Q:** When is the midterm? What does it cover?

**A:** **March 5**, **6:30–8:15 pm**. It covers **Labs 1–6** and **Lectures 1–19**. Lecture 19 is a review for the test. See Quercus for room and past tests.

---

## Lab 6 parts

**Q:** What is Lab 6 Part 1? Part 2?

**A:** **Part 1:** Use C pointers and dereferencing for memory-mapped I/O (Lecture 15 style) with **KEY buttons and LEDs**. **Part 2:** Copy microphone input to the speakers (Lecture 17 code) on the **real board** (not meaningful on CPUlator because the mic is replaced by a sawtooth).

**Q:** What is Part 3? What range of frequency do the switches control?

**A:** **Part 3:** Generate a **square wave** in code and send it to the speakers; use the **switches** to set the frequency between **100 Hz and 2000 Hz**.

**Q:** What is Part 4 in one sentence?

**A:** **Part 4:** Same as Part 2 (mic → speaker) but add **echo**: the sound from N sample periods ago is added back, **damped** by a factor D, so you hear delay and fade.

---

## Part 3: square wave

**Q:** What is a square wave in terms of sample values?

**A:** A waveform that alternates between a **high** value and a **low** value: many consecutive **high** samples, then many consecutive **low** samples, then high again, etc.

**Q:** Why use a “big” high value and a big negative low value for the 24-bit samples?

**A:** The samples are **24-bit signed**. If the values are too small in magnitude, the sound is inaudible or very quiet. Using a large positive (e.g. largest 24-bit positive) and a large negative makes the square wave **loud enough** to hear.

**Q:** What is the output sample rate of the D/A? What is the time between two consecutive output samples?

**A:** **8 kHz** (8000 samples per second). So the time between samples is **1/8000 s = 0.000125 s = 125 µs**.

**Q:** How do you know when it is safe to put the next sample into the output FIFO (Part 3)?

**A:** Check the **fifospace** (or struct): **WSRC** or **WSLC** gives the number of **empty** slots in the right/left output FIFO. If **WSRC > 0** (or WSLC > 0), there is room — you can **store** the next sample.

---

## Part 4: echo

**Q:** What is the “delay” N in the echo? What does the lab say N should be?

**A:** **N** is how many **sample periods ago** we take the sound to “echo” back. The lab says N should correspond to about **0.4 seconds** of delay — at 8 kHz that is **0.4 × 8000 = 3200** samples.

**Q:** What is the damping factor D? What range must it be in?

**A:** **D** is a multiplier that makes the echoed sound **quieter**. It must be **0 < D < 1**. You choose a good D by experimenting (on the real board; CPUlator has no real mic for echo).

**Q:** Why do we use Output(t − N) in the echo formula instead of Input(t − N)?

**A:** **Output(t − N)** already includes earlier echoes (from t−2N, t−3N, …) that were damped. So the formula **Output(t) = Input(t) + D × Output(t − N)** gives a natural **infinite fade** — repeated echoes getting quieter — without storing all past input. We only need to store the **last N output** samples in an array.

**Q:** What do we need to store in an array for the echo, and why?

**A:** We need to store the **last N values of Output** (the samples we previously sent to the output). So we can compute **Output(t − N)** when we compute Output(t). The array is a **circular buffer** or sliding window of the last N outputs.

---

## C structures for audio

**Q:** Why don’t we “reserve memory” for the audio struct? Where does the struct “live”?

**A:** The **registers are already in hardware** at **AUDIO_BASE**. We do not allocate the struct; we only create a **pointer** that points to that base address. The struct **overlays** the memory-mapped registers so each field lines up with the right register.

**Q:** Name the fields in the audio struct that correspond to (a) input FIFO counts, (b) output FIFO empty counts, (c) left/right data.

**A:** (a) **rarc**, **ralc** — right/left **input** FIFO (samples present). (b) **wsrc**, **wslc** — right/left **output** FIFO **empty** slots. (c) **ldata**, **rdata** — left/right **data** (read = input FIFO, write = output FIFO).

**Q:** In the pass-through loop with the struct, what does `if (audiop->rarc > 0)` ensure? For Part 3, what extra check should you add before writing to the output?

**A:** **rarc > 0** means there is **at least one sample** in the right input FIFO (and we assume left has data too), so we can **read** from both input FIFOs. For **Part 3**, you should also check that there is **room** in the output FIFO, e.g. **audiop->wsrc > 0** (or wslc), before **storing** to ldata/rdata, because you are generating the wave and must not overrun the output FIFO.

---

## True/False

**Q:** T/F: In Part 2, the code checks WSRC before writing to the output FIFO.

**A:** **False.** In the simple Part 2 pass-through, the **input** rate controls the rate, so we often don’t check output space. The lecture says you **should** check (e.g. **wsrc > 0**) and that you **need** to do that in **Part 3** when generating the square wave.

**Q:** T/F: The echo formula Output(t) = Input(t) + D × Input(t−N) gives the correct infinite fade.

**A:** **False.** The correct formula uses **Output(t−N)**, not Input(t−N). Output(t−N) already contains the faded echoes from 2N, 3N, … ago, so one term gives the full fading echo. Input(t−N) would only echo once.

**Q:** T/F: The struct audio_t is allocated in your C program’s heap or stack.

**A:** **False.** We **do not** allocate the struct. We only use a **pointer** to the **hardware base address** (AUDIO_BASE). The “struct” is a view of the **memory-mapped registers** that are already there.

---

End of practice. Use **L18_SUMMARY_Lab6_SquareWave_Echo_CStruct.md** to review.
