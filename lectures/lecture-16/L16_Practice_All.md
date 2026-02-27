# Lecture 16 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture 16**.

---

## Lecture context

**Q:** What does “today” cover in Lecture 16?

**A:** **Audio (sound) input and output** — how sound becomes digital samples (A/D), how digital samples become sound again (D/A), and how the DE1-SoC uses **FIFOs** to buffer samples so the computer can keep up.

---

**Q:** In one sentence, what does the A/D do? What does the D/A do?

**A:** The **A/D** converts the **analog** (continuous) voltage signal into a **sequence of digital (binary) samples**. The **D/A** converts a **sequence of digital values** from the processor back into an **analog voltage** waveform.

---

## Sampling and sample rate

**Q:** What does it mean to “sample” the analog waveform? What is the “sample rate”?

**A:** **Sampling** means taking the **value** of the analog signal at **specific instants in time** (e.g. the orange lines / red ticks on the waveform). The **sample rate** is **how many samples per second** (e.g. 10 kHz = 10,000 per second).

**Q:** If the sample rate is 10 kHz, how much time is there between two consecutive samples?

**A:** **100 microseconds (100 µs)**. One sample every 1/10,000 second = 0.0001 s = 100 µs.

**Q:** What sample rate and how many bits per sample does the DE1-SoC audio use?

**A:** **8 kHz** sample rate and **24 bits** per sample.

---

## Input and output path

**Q:** In order, what happens from the microphone to the processor (input path)?

**A:** **Sound waves** → **microphone** (to voltage) → **amplifier** → **analog voltage** → **A/D** (to digital samples) → (then into the system, e.g. **input FIFO** → processor reads).

**Q:** In order, what happens from the processor to the speaker (output path)?

**A:** **Processor** sends **digital samples** → **output FIFO** → **D/A** (to analog voltage) → **amplifier** → **speaker** → **sound waves**.

---

## Why buffer? FIFOs

**Q:** Why can’t the computer just read each input sample exactly when the A/D produces it?

**A:** Samples arrive at a **fixed, fast rate** (e.g. every 100 µs). The computer might be **busy** and **not ready** at that exact moment. So we need **temporary storage** — **buffering** — so samples can wait until the computer reads them.

**Q:** Why can’t the processor send each output sample exactly when the D/A needs it?

**A:** The D/A needs a new sample at **precise times**. The processor is **not very good** at delivering data at such exact intervals. So we use a **buffer** (output FIFO) that the D/A can **pull from** at the right time.

**Q:** What is a FIFO in this context? Is it software or hardware?

**A:** A **FIFO** is a **first-in, first-out** queue — the first value stored is the first one taken out. On the DE1-SoC audio it is **hardware**: a piece of memory-like hardware that the A/D fills (input) or the D/A drains (output), and the computer reads from or writes to via **memory-mapped** accesses.

**Q:** What happens if the computer does not read from the input FIFO in time?

**A:** The **input FIFO fills up**. When it is full and the A/D produces another sample, **samples are lost** (overrun). So the computer must read often enough to keep up.

---

## Memory-mapped access

**Q:** How does the computer get the “next” input audio sample? How does it send the “next” output sample?

**A:** A **load** (read) from the **memory-mapped address** of the **input FIFO** returns the **next sample** in the queue. A **store** (write) to the **memory-mapped address** of the **output FIFO** **places the next output sample** into the queue (for the D/A to use).

**Q:** How many samples can the DE1-SoC input FIFO hold (approximately)?

**A:** About **128 samples** (as stated in the lecture). If the FIFO fills beyond that and the computer doesn’t read in time, samples are lost.

---

## CODEC and board

**Q:** What is the CODEC on the DE1-SoC? What does it do?

**A:** The **CODEC** is a **chip** on the board that handles much of the audio path: **A/D**, **amplification**, **D/A**, and related functions. The computer talks to the audio system (e.g. FIFOs) that connect to this CODEC.

**Q:** Where is the microphone connected? Where is the speaker connected?

**A:** The **microphone** connects to the **input jack**; the **speaker** (or earbuds) connects to the **output jack** on the DE1-SoC.

---

## True/False

**Q:** T/F: The analog signal from the microphone is a sequence of numbers.

**A:** **False.** The **analog** signal is a **continuous voltage vs time**. The **sequence of numbers** is produced by the **A/D** after sampling.

**Q:** T/F: The sample rate is how many bits each sample has.

**A:** **False.** The **sample rate** is **how many samples per second** (e.g. 8 kHz). The **number of bits per sample** (e.g. 24) is a separate choice (resolution of each sample).

**Q:** T/F: The output FIFO is filled by the D/A and read by the processor.

**A:** **False.** The **processor** **writes** (stores) to the **output FIFO**; the **D/A** **reads** (pulls) from it at the correct times to produce the analog output.

---

End of practice. Use **L16_SUMMARY_Audio_IO.md** to review.
