# Lecture 15 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #15**.

---

## Lecture context

**Q:** What does “today” cover in Lecture 15?

**A:** **Connecting C and compilation to assembly**; using I/O devices in C; and the full computer system (leading to sound I/O). So we go from assembly to C and see how the same I/O ideas (memory-mapped pointers) appear in C.

---

**Q:** Why do engineers prefer higher-level languages? Why do we still teach assembly?

**A:** Engineers prefer **C/C++, Python, Java, Rust**, etc. because they are easier and faster to write and maintain. We teach **assembly** so you understand **what is going on underneath** — how the machine actually executes and how C maps to instructions and memory.

---

## Compilation and linking

**Q:** If you have more than one C file (e.g. file1.c, file2.c), what extra step is needed to get one program? What are the inputs and output?

**A:** You need a **linker**. The compiler produces **object files** (file1.o, file2.o, …). The **linker** combines those **.o** files into **one executable** (one machine-code file).

---

**Q:** What is the name of the final executable file in the DE1-SoC / gmake setup? What does it contain?

**A:** The final file is **file.axf** (or similar .axf name). It is the **executable** — a representation of the **final binary image** of the program and data that is loaded into memory.

---

## Startup code and _start vs main

**Q:** Does the C compiler (toolchain) only compile your code? What runs before your program?

**A:** No. The toolchain adds **startup code** that is **executed before** your program. So something runs first (e.g. at **_start**), then your code (e.g. **main**) is reached.

---

**Q:** Is _start the same as main? Who runs first?

**A:** **No.** **_start** is the **entry point** of the whole program (where the processor begins). The **startup code** runs first (e.g. at _start); it does setup and then typically **calls main**. So **_start** runs before **main**.

---

**Q:** On a bare-metal system like the DE1-SoC (no OS), what must the startup code do? Name at least two things.

**A:** It must (1) **set up the stack pointer**, and (2) **set/initialize uninitialized variables** (and any other runtime setup). Then it can call **main**.

---

## I/O in C

**Q:** In the C program that copies switches to LEDs, what do **SW_ptr** and **LEDR_ptr** represent? What type are they?

**A:** They are **pointers** to the **memory-mapped I/O addresses** of the switches (0xFF200040) and LEDs (0xFF200000). In C they are declared as **volatile int \*** and hold those addresses — the same idea as loading the address into a register in assembly (e.g. **la t0, LEDs**).

---

**Q:** What does **value = *SW_ptr;** do in terms of the processor? What does **\*LEDR_ptr = value;** do?

**A:** **value = *SW_ptr** **reads** the word at the address in SW_ptr (load from memory) — like **lw** in assembly. **\*LEDR_ptr = value** **writes** the word in **value** to the address in LEDR_ptr (store to memory) — like **sw** in assembly.

---

**Q:** Why do we use **volatile** for I/O pointers like SW_ptr and LEDR_ptr?

**A:** **volatile** tells the compiler **not to optimize** these accesses: (1) **Always access memory** when the code reads or writes — don’t keep the value only in a register, because the **hardware** can change I/O registers. (2) (Later) Don’t treat them as normal cached memory. Without volatile, the compiler might remove or reorder reads/writes and break I/O.

---

**Q:** In the demo, where does **main** end up? Where does **_start** end up? What does that show?

**A:** **main** might be at an address like **0x101ac**; **_start** at a different address like **0x10094**. That shows that **main is not _start** — the startup code is at _start, and main is a separate function called by the startup code.

---

## Full system and sound

**Q:** What document does the lecture use for the full computer system and sound I/O?

**A:** The **DE1-SoC Computer with Nios V** document (**DE1-SoC_Computer_NiosV.pdf**) given out in Lab 1. The lecture follows that from **_start** (and startup) through to **main** and the full system (including sound I/O).

---

## True/False

**Q:** T/F: On the DE1-SoC, the processor starts executing at the first instruction of **main**.

**A:** **False.** The processor starts at **_start**. The startup code runs first (e.g. sets stack, initializes variables), then it calls **main**.

---

**Q:** T/F: In C, **\*ptr** means “the address of ptr.”

**A:** **False.** **\*ptr** means **dereference** — the **contents** of the memory location whose address is in **ptr**. The “address of” operator in C is **&**.

---

**Q:** T/F: We use **volatile** so the compiler will optimize I/O accesses for speed.

**A:** **False.** We use **volatile** so the compiler will **not** optimize I/O away or reorder it — we want **every** read/write to actually go to memory (the I/O registers), because the hardware can change them.

---

End of practice. Use **L15_SUMMARY_C_Compilation_IO.md** to review.
