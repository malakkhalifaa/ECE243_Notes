# ECE 243 Lecture #9 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 3 next week — program to count 1's in a 32-bit number (using logic & shift; subroutines; LED output).
- **Last day:** The stack — push and pop in assembly; how the stack is used in subroutines (saving & restoring **`ra`**); the stack is also used for many other important things.
- **Today:** Introduction to **Memory-Mapped I/O** (the connection between the virtual and physical world); at the end: rules on using registers to send information into subroutines and receive it back, and using the stack — the **Nios V / RISC-V Calling Convention**.

---

## Part 1: Memory-Mapped Input/Output

### What it is
- **Memory-mapped I/O** is the **connection between the virtual (internal-to-computer) world and the physical (real) world**.
- Recall the **DE1-SoC board** (used in ECE 241). It has these I/Os:
  - **10 LEDs** (LEDR 9:0)
  - **10 slider switches** (SW 9:0)
  - **4 buttons** (KEY 3:0)
  - **6 seven-segment displays** (SEG7 5:0)
- These same I/Os are available to the **Nios V** processor, but are **accessed in software** — through circuits that are part of the processor system on the FPGA.
- This method (**memory-mapped I/O**) is used in **all processors**.

### How it works
- Recall basic computer architecture: the processor places the **address** it wants to read/write on the **address bus**; **memory** responds by putting the data at that address on the **data bus** (for **`lw`**); similarly for **`sw`** to store.
- **New:** Only a **subset of addresses** are associated (“mapped”) to **memory** (most of them, not all). A digital circuit makes that happen.
- **Some addresses** are mapped to **I/O devices** (LEDs, switches, etc.).
- So we use **`lw`** and **`sw`** for **both** memory and I/O — the **hardware knows by the address** what you actually want. That is **memory-mapped I/O**.

### DE1-SoC addresses (this course)
- **LEDs (outputs):** The state (on/off) of the **10 LEDs** is mapped to the **low-order 10 bits** at address **0xFF200000**.
- **Switches (inputs):** The **10 switches** are mapped to the **low-order 10 bits** at address **0xFF200040**.

### Example program: copy switches to LEDs
Continuously **load** the switches and **store** those values into the LEDs:

```asm
.equ LEDs, 0xFF200000    # .equ sets symbol LEDs to be that number (ease of reading)
.equ SW,  0xFF200040    # the switches address

_start:  la  t0, LEDs   # get LED address into t0: t0 <- 0xFF200000
         la  t1, SW     # get SW  address into t1: t1 <- 0xFF200040
loop:    lw  t2, (t1)   # load the 10 switches value into t2
         sw  t2, (t0)   # store the 10 values into the LEDs
         j   loop       # do it over and over
```

- **`lw`** and **`sw`** are used for **both** I/O and memory; the hardware uses the **address** to decide whether it’s memory or I/O.

---

## Part 2: Calling Convention (Nios V / RISC-V)

### Why we need rules
- Recall: the stack is used to save and restore **`ra`** in **nested** subroutine calls (subroutines that call subroutines).
- **Issue:** Different subroutines use registers differently (e.g. sub_1 might use `t0` for one thing, sub_2 for another). We must **guarantee** that code we call doesn’t **destroy** important values in our registers, or the program won’t work.
- **Solution:** We make **rules** and everyone follows them. (Compilers know the rules; in assembly you must obey them.)

### Terminology
- **Caller** — the code that is **calling** another subroutine.
- **Callee** — the subroutine that is **being called** (launched).
- Code can be **both**: e.g. **sub_1** is the **callee** when called from main, and the **caller** when it calls sub_2.

### The Nios V / RISC-V calling convention (this course)

**1. Parameters (caller → callee)**  
- The **first 8 parameters** are put in registers **a0, a1, a2, a3, a4, a5, a6, a7** (“a” = **argument**).  
- If there are **more than 8** parameters, they must be **pushed onto the stack**. The **caller** is responsible for **pushing** them and **popping** them off when the callee returns.

**2. Return values (callee → caller)**  
- **One word** returned: put in **a0**.  
- **Second word** returned: put in **a1**.  
- If **more than two** items are returned, the **callee** pushes them onto the stack and the **caller** pops them off.

**3. Registers t0–t6 (“temporaries”) — caller-saved**  
- The **caller** is responsible for **saving** these registers (e.g. on the stack) **before** calling a subroutine if it wants to **preserve** them for use **after** the call, and **restoring** them after the callee returns.  
- So we call **t0–t6** the **“caller-saved”** registers — the **caller** takes that responsibility.

**4. Registers s0–s11 — callee-saved**  
- These are the **callee’s** responsibility. If the **callee** wants to use **s0–s11**, it must **save** their contents (e.g. on the stack) **before** changing them, use them, then **restore** them before returning.  
- So we call **s0–s11** the **“callee-saved”** registers.  
- If you don’t save them, **CPUlator** can report that you **clobbered** those registers (you can turn that check off in CPUlator settings).

### When these rules matter
- **Not yet in Lab 3**, but in **Labs 4 & 5**.  
- On **midterm and final**: the rules will be included (you need to **understand** them, not necessarily memorize them).

---

## Quick reference

### Memory-mapped I/O
| Item | Meaning |
|------|---------|
| **Memory-mapped I/O** | I/O devices are accessed by **addresses**; we use **`lw`** / **`sw`** for both memory and I/O; hardware uses address to decide. |
| **LEDs** | **0xFF200000** — low-order 10 bits = state of 10 LEDs (output). |
| **Switches** | **0xFF200040** — low-order 10 bits = state of 10 switches (input). |
| **.equ** | Sets a symbol to a number (e.g. `.equ LEDs, 0xFF200000`) for readability. |

### Calling convention
| Item | Meaning |
|------|---------|
| **Caller** | Code that **calls** another subroutine. |
| **Callee** | Subroutine that is **called**. |
| **Parameters (first 8)** | **a0–a7** (caller puts them there). |
| **Parameters (> 8)** | Pushed on stack by **caller**; caller pops after return. |
| **Return (1 word)** | **a0**. |
| **Return (2 words)** | **a0**, **a1**. |
| **Return (> 2)** | Callee pushes on stack; **caller** pops. |
| **t0–t6** | **Caller-saved** — caller saves/restores if it needs them after the call. |
| **s0–s11** | **Callee-saved** — callee saves/restores if it uses them. |
