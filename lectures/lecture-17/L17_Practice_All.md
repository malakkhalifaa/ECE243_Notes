# Lecture 17 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture 17**.

---

## Lecture context

**Q:** What does “today” cover in Lecture 17?

**A:** **Audio Part 2** — **register-level control** of the DE1-SoC audio interface, how **sound data** flows through the FIFOs, and **example code** that copies microphone input to speaker output (pass-through).

---

**Q:** In one sentence, what does the processor talk to directly — the A/D and D/A, or the FIFOs?

**A:** The processor talks **only to the input and output FIFOs** (via memory-mapped registers), not directly to the A/D or D/A.

---

## Recall: FIFOs and timing

**Q:** What happens if the computer does not read from the input FIFO in time?

**A:** The **input FIFO fills up** (up to 128 samples on DE1-SoC). When it is full and the A/D produces another sample, **samples are lost**.

**Q:** Why must the computer put samples into the output FIFO regularly?

**A:** The **D/A** takes a **new sample every sample period** (e.g. every 100 µs). If the output FIFO doesn’t have a sample ready when the D/A needs it, you get **bad or missing sound**.

---

## Registers: Leftdata and Rightdata

**Q:** Does the same memory-mapped address (e.g. Leftdata) correspond to one FIFO or two? How do you tell?

**A:** **Two** — one for **input** and one for **output**. A **load (read)** accesses the **input** FIFO; a **store (write)** accesses the **output** FIFO. The **R/W** (read/write) control selects which.

**Q:** When you **load** from Leftdata, what happens to that sample in the input FIFO?

**A:** That sample is **removed** from the left input FIFO. The **next** load from Leftdata returns the **next** sample (first-in, first-out).

**Q:** When you **store** to Leftdata, where does the value go? Who eventually uses it?

**A:** The value is **added** to the **left output FIFO**. The **D/A** later **removes** it at the correct time to produce the analog output.

---

## fifospace register

**Q:** What do RALC and RARC represent? What do WSLC and WSRC represent?

**A:** **RALC** = number of **left input** FIFO slots **used** (of 128). **RARC** = same for **right input**. **WSLC** = number of **left output** FIFO slots **empty**. **WSRC** = same for **right output**.

**Q:** When the input FIFOs are cleared, what are RALC and RARC? When the output FIFOs are cleared, what are WSLC and WSRC?

**A:** **Input cleared:** RALC = RARC = **0** (no slots used). **Output cleared:** WSLC = WSRC = **128** (all slots empty).

---

## Control and status register

**Q:** The register at 0xFF203040 is used both as control and as status. How do you use it as control? As status?

**A:** **Write** to it to use it as **control** (e.g. clear FIFOs). **Read** from it to use it as **status** (e.g. how full the FIFOs are, or flags like RI, WI).

**Q:** How do you clear the input FIFOs? How do you clear the output FIFOs?

**A:** **Write** to the control register: set **CR = 1** to **clear the input FIFOs**; set **CW = 1** to **clear the output FIFOs**. (Do this at program start if you want a clean state.)

**Q:** What does the RI status bit mean when it is 1? What does WI mean when it is 1?

**A:** **RI = 1** means the **input** FIFO is **75% or more full** — the processor should read soon. **WI = 1** means the **output** FIFO is **≤ 25% full** — it needs more samples soon.

---

## Pass-through program (Lab 6 Part II)

**Q:** What is the goal of the pass-through program?

**A:** **Copy** every input sample (from the microphone) to the output (to the speaker), for **both left and right** channels — so you hear what goes into the mic.

**Q:** In the example code, what does `fifospace = *(audio_ptr + 1)` do? Why do we check `(fifospace & 0x000000FF) > 0`?

**A:** It **reads the fifospace** register. The **low byte** (mask 0xFF) gives **RARC** — how many samples are in the **right input** FIFO. If it’s **> 0**, there is at least one sample ready to read (and we assume left has data when right does), so we read both channels and write to output.

**Q:** After `left = *(audio_ptr + 2)` and `right = *(audio_ptr + 3)`, what do we do with `left` and `right`? What effect do those two reads have on the input FIFOs?

**A:** We **write** them to the output: `*(audio_ptr + 2) = left;` `*(audio_ptr + 3) = right;`. The two **reads** **remove** one sample from each **input** FIFO (left and right).

**Q:** Why does the lecture say “the timing of the input FIFO controls the timing of the output” in this program?

**A:** We only **read and write** when the **input** FIFO has data. So how often we get new input samples determines how often we send output samples. That keeps the program simple and naturally matches input rate to output rate.

---

## Demo and Lab 6

**Q:** Why might CPUlator not give real microphone input? What might you hear instead?

**A:** CPUlator is a **simulator** and may not have a real microphone. You might get a **synthetic** signal (e.g. a **sawtooth** wave) that “doesn’t sound so good” instead of real mic input. On the **real board** you get actual mic → speaker.

**Q:** What are the four parts of Lab 6 (briefly)?

**A:** **Part 1:** Use C for simple LED/switches I/O. **Part 2:** Copy input sound to output (pass-through). **Part 3:** Sound generator with **variable-frequency square wave**. **Part 4:** **Echo box** — revise Part 2 to add echo (next day).

---

## True/False

**Q:** T/F: Loading from Leftdata adds a sample to the left output FIFO.

**A:** **False.** **Loading** from Leftdata **reads (and removes)** a sample from the **left input** FIFO. **Storing** to Leftdata adds a sample to the **left output** FIFO.

**Q:** T/F: When the output FIFO is empty, WSRC and WSLC are 0.

**A:** **False.** **WSLC** and **WSRC** are the number of **empty** slots. When the output FIFO is **empty**, all 128 slots are empty, so **WSLC = WSRC = 128**.

**Q:** T/F: The same physical FIFO hardware is used for both reading (input) and writing (output) at Leftdata.

**A:** **False.** The **same address** (Leftdata) is used for **two different** FIFOs: a **read** accesses the **input** FIFO; a **write** accesses the **output** FIFO. They are separate hardware FIFOs.

---

End of practice. Use **L17_SUMMARY_Audio_Part2_Registers.md** to review.
