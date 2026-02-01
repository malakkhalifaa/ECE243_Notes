# ECE 243 Lecture #10 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 3 this week; Lab 4 posted Wednesday.
- **Last day:** Introduction to Memory-Mapped I/O (connection between virtual and physical world); brief on rules for registers/stack in communication to/from subroutines — **Nios V Calling Convention** (reviewed in Lab 4; read that closely to really understand it).
- **Today:** More on I/O — **the Polling Method of Synchronization** and **Parallel Ports**.

---

## Recall: Memory-Mapped I/O
- **Memory-mapped I/O:** Specific **memory addresses** are assigned to **I/O devices** (not actual memory). Digital circuits route memory operations either to **memory** or to **LEDs**, **switches**, etc.
- Last day: LEDs (outputs) and Switches (inputs) as examples.

**Important:** LEDs and Switches are connected to **local (hardware) registers** that drive/receive the physical LEDs and switches.
- These **hardware registers** are **unrelated to the processor registers** (x0–x31, etc.).
- There are **10 D-type flip-flops** each for LEDs and for Switches.
- There are also registers for **SEG7** hex displays, **KEY** pushbuttons, **hardware timer**, and other devices (sound I/O, graphics I/O).

---

## The problem: How does the processor “know” when I/O is ready?
- The processor has a lot of work besides I/O (lights, sounds, network, graphics, …). We need to **coordinate** I/O with other tasks.
- **Input:** How does the processor know that a human has **finished** setting the switches and wants the computer to take in that number? Same for pushbuttons, network (new message), keyboard (new key), …
- **Output:** The processor needs to know when an **output** has finished being sent.

**Two methods** (like in class: ask everyone in turn vs. raise your hand and interrupt):
1. **Polling method of I/O** — Lab 4 & today.
2. **Interrupt method of I/O** — Lab 5.

---

## KEY pushbuttons on the DE1-SoC
- **4 keys:** Key 0, Key 1, Key 2, Key 3.
- **Base address:** **0xFF200050** (KEY_BASE).

| Offset from base | Register              | Notes                    |
|------------------|------------------------|--------------------------|
| 0x00             | **Data Register**      | Bit i = state of Key i   |
| 0x04             | Direction Reg          | (ignore for now)        |
| 0x08             | Interrupt Mask Reg     |                          |
| 0x0C             | **Edge Capture Reg**   | Bit i = edge detected    |

---

## Data Register (offset 0 from KEY_BASE)
- **When Key i is pressed:** bit i of the Data Register is **1**.
- **When Key i is released:** bit i is **0**.
- So Key 0 = bit 0, Key 1 = bit 1, Key 2 = bit 2, Key 3 = bit 3.
- The value **changes continuously** with press/release — the processor might **miss** a quick press/release if it doesn’t read at the right time.

---

## Edge Capture Register (offset 0x0C from KEY_BASE)
- **Behaviour (very different from Data Register):**
  - **Pressing and releasing** Key i sets **bit i** of the Edge Capture Register to **1**.
  - The bit **stays 1** until **software** resets it back to **0**.
  - So no push/release is “missed” — the processor can poll later and still see that a button was pressed and released.
- **How to clear (reset) a bit:**
  - **Writing 1** into a bit **sets that bit to 0** (clears it).
  - **Writing 0** into a bit **leaves it unchanged** (either 0 or 1).
  - So to clear bit 2 (Key 2), we **store a word that has bit 2 = 1** (e.g. 0x4) to the Edge Capture Register. “Wacky at first — storing 1 turns it off.”

---

## Polling
- **Polling** = **checking over and over again** in a loop (e.g. load the register, test a bit, branch back if not what we want).
- **How do you write code to see if a button has been pressed? You must poll!**

**Example: Polling loop to wait until Key 1 is pressed (Data Register):**
```asm
.equ KEY_BASE, 0xFF200050
la   t0, KEY_BASE        # get that address into a register
poll:
    lw   t1, (t0)        # load the Data Register
    andi t1, t1, 0x2     # Key 1 is bit 1 (0x2 = 0010); keep only bit 1
    beqz t1, poll        # if bit 1 is 0, Key 1 not down -> loop back
# execution arrives here only after Key 1 is pressed (stays in loop until then)
```

- **Lab 4 Part I:** Wait for **press and release** using the Data Register (must poll until 1, then poll until 0 — takes many cycles).
- **Lab 4 Part II and later:** Use the **Edge Capture Register** — only need to watch for **one** change (press+release sets the bit); then **reset** that bit by writing 1 to it.

---

## Example programs from the lecture

**1. Copy Data Register to LEDs** (CopyDataToLED.s)  
- Loop: load KEY Data Register (offset 0), store to LEDs. Any button press is immediately visible on the LEDs. Different from Edge Capture, which only changes when the button is both pressed **and** released.

**2. Copy Edge Capture to LEDs AND Switches to Edge Capture** (CopyEdgeCapToLEDsANDSWtoEdgeCap.s)  
- Loop: load Edge Capture Reg (offset 0xC), store to LEDs (so you can see it); load Switches, store to Edge Capture Reg (to demonstrate: writing 1 to a bit clears that bit, writing 0 leaves it unchanged). Turn off CPUlator “I/O device Warnings” in settings if needed.

**3. Button press/release using Edge Capture — flip LED 0 on each Key 2 press+release**  
- Poll Edge Capture (offset 0xC); **andi** with 0x4 to select Key 2 (bit 2). When bit is 1, a press+release happened: turn LED 0 on/off (flip with **xori**), then **clear** the edge capture bit by **storing 0x4** (a 1 in bit 2) to the Edge Capture Register (offset 0xC). Then jump back to poll.

---

## Quick reference

| Item | Meaning |
|------|---------|
| **Polling** | Repeatedly check (load, test, branch) in a loop until I/O is in the desired state. |
| **KEY_BASE** | **0xFF200050** — base address of KEY parallel port. |
| **Data Reg** | Offset **0** — bit i = 1 when Key i pressed, 0 when released. |
| **Edge Capture Reg** | Offset **0x0C** — bit i = 1 after Key i press+release; stays 1 until software clears it. |
| **Clear Edge Capture bit** | **Store 1** in that bit (e.g. store 0x4 to clear bit 2) — storing 1 sets the bit to 0; storing 0 leaves it unchanged. |
| **Polling loop** | Load register → **andi** to select bit → **beqz** back to loop if not set (or not cleared, depending on what you want). |
