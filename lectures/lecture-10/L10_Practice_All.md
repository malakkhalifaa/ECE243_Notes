# Lecture 10 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #10**.

---

## Lecture context

**Q:** What does “last day” cover in Lecture 10? What does “today” cover?

**A:** **Last day:** Introduction to Memory-Mapped I/O (virtual/physical world); brief on Nios V Calling Convention (registers/stack for subroutines — reviewed in Lab 4). **Today:** More on I/O — **the Polling Method of Synchronization** and **Parallel Ports** (KEY pushbuttons, Data Register, Edge Capture Register).

---

## Hardware registers and I/O

**Q:** Are the LEDs and Switches connected directly to the processor registers (e.g. t0, t1)? What are they connected to?

**A:** **No.** They are connected to **local (hardware) registers** — these are **unrelated to the processor registers**. Those hardware registers (e.g. 10 D-type flip-flops for LEDs, 10 for Switches) then drive/receive the physical LEDs and switches.

---

**Q:** Why do we need to coordinate I/O with other tasks? What two methods does the lecture give (like “ask everyone in turn” vs “raise your hand”)?

**A:** The processor has a lot of work besides I/O (lights, sounds, network, graphics). We need to **coordinate** when to do I/O. The two methods: **(1) Polling** — like asking everyone in turn if they have a question; **(2) Interrupt** — like raising your hand to interrupt. Polling is Lab 4 & today; Interrupt is Lab 5.

---

## KEY pushbuttons and registers

**Q:** What is the base address of the KEY pushbuttons on the DE1-SoC? How many keys are there?

**A:** **KEY_BASE = 0xFF200050.** There are **4 keys** (Key 0, Key 1, Key 2, Key 3).

---

**Q:** What is the Data Register for the KEY port? What is its offset from KEY_BASE? What does bit i represent?

**A:** The **Data Register** is at **offset 0** from KEY_BASE (so address 0xFF200050). **Bit i** = **1** when **Key i is pressed**, **0** when **Key i is released**. So it reflects the **current** state of the keys.

---

**Q:** What is the Edge Capture Register? What is its offset from KEY_BASE? How is its behaviour different from the Data Register?

**A:** The **Edge Capture Register** is at **offset 0x0C** (12) from KEY_BASE (so 0xFF20005C). **Pressing and releasing** Key i sets **bit i to 1**; the bit **stays 1** until **software** clears it. So it “captures” that a press+release **happened** — the processor can’t miss it because it doesn’t go back to 0 by itself. The Data Register goes 1 then 0 as you press and release; the processor might miss that if it doesn’t read at the right time.

---

**Q:** How do you **clear** (reset) a specific bit in the Edge Capture Register? What happens if you write 0 into that bit?

**A:** You **write 1** into that bit to **clear** it (set it to 0). So e.g. to clear bit 2, you **store 0x4** (binary 0100) to the Edge Capture Register. **Writing 0** into a bit **leaves it unchanged** (either 0 or 1). So “storing 1 turns it off; storing 0 leaves it as is.”

---

**Q:** Why is the Edge Capture Register useful for detecting a button press and release? Why might we prefer it over the Data Register in Lab 4 Part II?

**A:** With the **Data Register**, you must **poll** until you see 1 (pressed), then poll until you see 0 (released) — that takes **many cycles** and you can miss a fast press/release. With the **Edge Capture Register**, you only need to **watch for one change** (the bit goes to 1 when press+release happens) and then **clear** that bit. So you don’t miss events, and the code is simpler for “one event per press+release.”

---

## Polling

**Q:** What is the “polling method” of I/O? In code, what does a polling loop look like (in words)?

**A:** **Polling** = **checking over and over again** in a loop — load the I/O register, test the bit(s) you care about, and **branch back** to the load if the condition isn’t met yet. So: **load → test (e.g. andi, beqz) → branch back** until the condition is satisfied.

---

**Q:** To wait until Key 1 is pressed using the Data Register, we load the Data Register, then “select” only bit 1. What instruction do we use to keep only bit 1? What value do we AND with? Then what do we do if we want to keep looping until Key 1 is down?

**A:** We use **`andi t1, t1, 0x2`** — Key 1 is **bit 1**, and **0x2 = 0010** in binary, so this keeps only bit 1 and sets all other bits to 0. Then we use **`beqz t1, poll`** — if the result is 0, Key 1 is **not** down, so we **branch back** to the poll label. We only “fall out” of the loop when bit 1 is 1 (Key 1 pressed).

---

**Q:** In the Edge Capture program that flips LED 0 on each Key 2 press+release, after we detect that bit 2 of the Edge Capture Register is 1, we must do something before going back to the poll loop. What is it and why?

**A:** We must **clear** bit 2 of the Edge Capture Register by **writing 1** to that bit (e.g. store **0x4** to the Edge Capture Register at offset 0xC). If we don’t clear it, the bit stays 1 and the next time through the loop we would think another press+release happened. Clearing it lets us detect the **next** press+release.

---

## True/False

**Q:** T/F: The Data Register and the Edge Capture Register both go back to 0 automatically when you release the key.

**A:** **False.** The **Data Register** goes to 0 when you release the key. The **Edge Capture Register** bit **stays 1** until **software** clears it by writing 1 to that bit.

---

**Q:** T/F: To clear bit 2 of the Edge Capture Register, you store 0 into that bit.

**A:** **False.** You **store 1** into that bit (e.g. store a word with bit 2 = 1, like 0x4) to **clear** it. Storing 0 leaves the bit unchanged.

---

**Q:** T/F: Polling means the processor checks the I/O device once and then continues.

**A:** **False.** **Polling** means the processor **repeatedly** checks (in a loop) until the I/O is in the desired state — load, test, branch back.

---

**Q:** T/F: The KEY Data Register at offset 0 holds the current state of the four keys (1 = pressed, 0 = released).

**A:** **True.** Bit i = 1 when Key i is pressed, 0 when released.

---

## Multiple choice

**Q:** The KEY parallel port base address is: (a) 0xFF200000  (b) 0xFF200040  (c) 0xFF200050  (d) 0x20000

**A:** **(c) 0xFF200050.** 0xFF200000 is LEDs; 0xFF200040 is switches.

---

**Q:** The Edge Capture Register is at offset ___ from KEY_BASE. (a) 0  (b) 4  (c) 8  (d) 12 (0xC)

**A:** **(d) 12 (0xC).** Offset 0 is Data Register; 0x0C is Edge Capture.

---

**Q:** To wait until Key 2 is pressed (Data Register), we AND the Data Register with: (a) 0x1  (b) 0x2  (c) 0x4  (d) 0x8

**A:** **(c) 0x4.** Key 2 is **bit 2**; 0x4 = 0100 in binary.

---

**Q:** After detecting a Key 2 press+release via the Edge Capture Register, we clear bit 2 by storing ___ to the Edge Capture Register. (a) 0  (b) 1  (c) 0x4  (d) 0xFF

**A:** **(c) 0x4.** We **write 1** into bit 2 to clear it; 0x4 has bit 2 set. Storing 0 would leave the bit unchanged.

---

## Code / offsets

**Q:** Write the instruction to load the **Edge Capture Register** into `t3` assuming `t0` holds KEY_BASE.

**A:** **`lw t3, 0xC(t0)`** — offset 0xC (12) from KEY_BASE.

---

**Q:** Write the instruction to store the value in `t4` into the **Edge Capture Register** assuming `t0` holds KEY_BASE (e.g. to clear a bit by writing 1).

**A:** **`sw t4, 0xC(t0)`** — store to offset 0xC from KEY_BASE.

---

**Q:** Key 0 is bit ___, Key 1 is bit ___, Key 2 is bit ___, Key 3 is bit ___. What hex value do we use in `andi` to select Key 3 only?

**A:** Key 0 = bit **0**, Key 1 = bit **1**, Key 2 = bit **2**, Key 3 = bit **3**. To select only Key 3 we use **0x8** (binary 1000) in **`andi`**.

---

End of practice. Use **L10_SUMMARY_Polling_ParallelPorts.md** and the example `.s` files in this folder to review.
