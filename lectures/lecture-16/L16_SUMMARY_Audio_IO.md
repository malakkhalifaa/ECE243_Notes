# ECE 243 Lecture 16 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 5; Lab 6 after Reading Week.
- **Last day:** Connecting C language to assembly language coding.
- **Today:** **Audio (sound) input and output** — from analog sound to digital samples and back; buffering and FIFOs on the DE1-SoC.

---

## 1. The big picture
- Recording, storage, and playback of music involve several computers. Other ECE courses (e.g. ECE 231, ECE 216, and beyond) cover signal processing and the circuits; here we see how the **computer** fits in: it handles **digital samples** and talks to **A/D** and **D/A** hardware.

---

## 2. Sound input: from sound to digital samples
- **Source** (e.g. band) → **microphones** convert sound waves to a **low voltage signal** → **amplifier** → **analog signal** (voltage vs time — continuous).
- **Analog-to-Digital Converter (A/D)** converts this **analog** signal into **digital samples**:
  - The A/D **samples** the waveform at **specific time intervals** (e.g. vertical lines / ticks on a voltage-vs-time plot).
  - **Sample rate** = how many samples per second. Example: **10 kHz** = 10,000 samples per second = **one sample every 100 microseconds (100 µs)**.
  - Each sample is a **digital (binary) value** that can be read by the processor.
- Example sequence: at 100 µs → value 2; 200 µs → 3; 300 µs → 4; 400 µs → 5; 500 µs → 3; 600 µs → 2. These numbers can be stored in memory or processed on a system like the DE1-SoC.
- **DE1-SoC audio:** **24 bits** per sample; sample rate **8 kHz** (not 10 kHz).

---

## 3. Sound output: from digital samples to sound
- The **processor** sends a **sequence of digital values** at a **fixed rate**.
- These values go to a **Digital-to-Analog converter (D/A)**, which **recreates the analog waveform** (voltage vs time).
- That signal is **amplified** and sent to a **speaker** (or earbuds), which converts it back into **sound waves** you hear.
- So: **sequence of numbers** (from processor) → D/A → analog voltage → amplifier → speaker → sound.

---

## 4. DE1-SoC: jacks and CODEC
- The DE1-SoC has an **input jack** (microphone) and an **output jack** (speaker).
- A **CODEC** chip on the board does much of the work: **A/D**, **amplification**, **D/A**, and more.

---

## 5. Why buffering? Two issues
1. **Input:** Samples **arrive** at a fixed rate (e.g. every ~100 µs). That is **fast**; the processor might be busy and **not ready** to read each one exactly when it arrives. So incoming samples must be **stored temporarily** — **buffered** — until the computer reads them.
2. **Output:** Output samples must be **sent at exactly** the right time (e.g. every 100 µs). The processor is **not very good** at delivering data at such precise times. So we need **temporary storage** on the output side too — the hardware can **pull** the next sample at the right time.

---

## 6. FIFO: hardware buffer
- The extra hardware that does this **buffering** is a **FIFO** — **first-in, first-out** queue (like in software, but in **hardware**).
  - When the **computer** reads from the **input FIFO**, it gets the **“first out”** sample (the oldest one that was put in by the A/D).
  - When the **computer** writes to the **output FIFO**, it is **“first in”**; the D/A later takes the **“first out”** at the correct time.
- The DE1-SoC audio uses **input FIFOs** and **output FIFOs**.

---

## 7. Mic → computer → speaker (pass-through idea)
- Conceptually: **A/D** → **input FIFO** → **computer** (read sample, write sample) → **output FIFO** → **D/A** → speaker. The same sequence of numbers (e.g. 2.5, 3.5, 5, 4, 3, 2) flows: in from mic, through the computer, out to speaker.

---

## 8. Input FIFO (DE1-SoC)
- The **input FIFO** is fed by the **A/D** and stores a **sequence of samples** up to a **limit** (e.g. **128 samples** on the DE1-SoC).
- If the **computer does not read** (load) from the FIFO **in time**, the FIFO **fills up** and **samples are lost** (overrun).
- A **load** (read) by the computer from the **memory-mapped address** of the input FIFO **gets the next sample** from the sequence.

---

## 9. Output FIFO (DE1-SoC)
- A **store** (write) by the computer to the **memory-mapped address** of the output FIFO **places the next output sample** onto the output FIFO.
- The **D/A** **pulls** from the output FIFO **in time** at the sample rate.
- There are **memory-mapped registers** for both the **load** (input) and **store** (output). Details (addresses, control registers) are in the **next lecture**.

---

## Quick reference
| Item | Meaning |
|------|--------|
| **A/D** | Analog-to-Digital: converts analog voltage to digital samples at a sample rate. |
| **D/A** | Digital-to-Analog: converts sequence of digital values to analog voltage. |
| **Sample rate** | Samples per second (e.g. 8 kHz = 8000/s; 10 kHz = one every 100 µs). |
| **DE1-SoC audio** | 24 bits per sample; 8 kHz. Input/output jacks; CODEC chip. |
| **Buffering** | Temporary storage so the computer doesn’t have to be ready at every sample instant. |
| **FIFO** | First-in, first-out queue (hardware); input FIFO from A/D, output FIFO to D/A. |
| **Load from input FIFO** | Read next sample (memory-mapped). |
| **Store to output FIFO** | Write next output sample (memory-mapped). |
