# ECE 243 Lecture 15 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 5; interrupts next week.
- **Last day:** Interrupts Part 3 — the code for one interrupt (KEYs).
- **Today:** **Connecting C and compilation to assembly**; using I/O devices in C; full system and sound I/O.

---

## 1. Why we use C (and why we learned assembly)
- Engineers usually prefer **higher-level languages**: C/C++, Python, Java, Rust, Go, JavaScript, TypeScript. (Rust is often used for systems work; the course uses C.)
- We teach **assembly** so you understand **what is going on underneath**.
- Now we connect **C** and **compilation** to that picture.

---

## 2. Multiple C files and the linker
- If you have **more than one C file** (e.g. file1.c, file2.c), the compiler produces **object files** (file1.o, file2.o, …).
- A **linker** combines all **.o** files into **one executable** (one machine-code program).
- On the DE1-SoC with the course **gmake** script, the final executable is **file.axf** — it contains the **binary image** of the program and data that goes into memory.

---

## 3. Startup code: _start is not main
- The **C compiler** (toolchain) adds **startup code** that runs **before** your program.
- So **\_start** is **not** the same as **main**.
- On a **bare-metal** system (no OS) like the DE1-SoC, the startup code must do things such as:
  - **Set up the stack pointer**
  - **Initialize uninitialized variables** (and any other runtime setup)
- Then it typically **calls** your **main**. So execution goes: **_start** then startup then **main** then your code.

---

## 4. I/O in C: same idea as assembly
- **Recall (Lecture 9):** In assembly we copy the 10 switches into the 10 LEDs in a loop using memory-mapped I/O at **LEDs = 0xFF200000** and **SW = 0xFF200040**.
- In **C** we do the same by treating those addresses as **pointers** and **dereferencing** them.

---

## 5. C program: switches to LEDs
```c
int main(void)
{
    volatile int *SW_ptr   = (int *) 0xFF200040;
    volatile int *LEDR_ptr = (int *) 0xFF200000;
    int value;
    while (1) {
        value = *SW_ptr;      /* load from switches  — like lw */
        *LEDR_ptr = value;   /* store to LEDs       — like sw */
    }
}
```
- **Pointers:** SW_ptr and LEDR_ptr hold the **addresses** of the I/O registers (same as in assembly).
- **Dereference:** **\*SW_ptr** reads the word at that address (like **lw**); **\*LEDR_ptr = value** writes (like **sw**).

---

## 6. Why volatile
- **volatile** tells the **compiler** not to optimize these accesses:
  - **Do not** keep the value only in a register — **always read from or write to memory** when the code says so. (I/O registers can change due to hardware.)
  - (Later: it also relates to **cache** — we want I/O to go to actual device memory.)
- Without **volatile**, the compiler might optimize away or reorder reads/writes and break I/O.

---

## 7. Where main and _start live
- In the demo (e.g. simple.c, around.c), **main** ends up at an address such as **0x101ac**; **_start** is at a different address (e.g. **0x10094**).
- This shows that **main is not _start** — the startup code runs first, then calls main.

---

## 8. Full computer system and sound I/O
- The lecture uses the **DE1-SoC Computer with Nios V** document (DE1-SoC_Computer_NiosV.pdf, from Lab 1).
- The path is: **_start** (and startup) then **main** then your C code (e.g. switches/LEDs, or later **sound input/output**).

---

## Quick reference
| Item | Meaning |
|------|--------|
| **Linker** | Combines .o files into one executable (e.g. .axf). |
| **.axf** | Final executable (binary image) for DE1-SoC. |
| **_start** | Entry point of the whole program; runs startup code first. |
| **main** | Where your C code starts; called by startup. |
| **Startup (bare metal)** | Sets stack pointer, initializes variables, then calls main. |
| **I/O in C** | Use pointers to I/O addresses; *ptr = read (like lw), *ptr = x = write (like sw). |
| **volatile** | Always access memory; do not optimize away I/O accesses. |
