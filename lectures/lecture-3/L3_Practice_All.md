# Lecture 3 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #3**.

---

## Lecture context

**Q:** What does “today” cover in Lecture 3?

**A:** **Memory organization** in the Nios V processor — how programs and data are organized in memory, and an example program that adds three numbers in memory.

---

**Q:** What is the assembler’s job with respect to assembly code and memory?

**A:** The assembler **translates** assembly into **machine code** (numbers) and **places that code into memory**. The processor later **reads instructions from memory** to execute them.

---

## 32-bit processor and memory

**Q:** What does it mean that Nios V is a “32-bit” processor? (Give at least two implications.)

**A:** (1) **Registers** are **32 bits** wide. (2) There are **2^32** addressable memory locations (~4 billion). (3) The **word size** is 32 bits — the typical amount of information accessed from memory at one time. (4) We can also access **8 bits (byte)** or **16 bits (halfword)**.

---

**Q:** What does “byte addressable” mean?

**A:** **Every byte (8 bits)** has its **own address**. So we can refer to memory one byte at a time, even though we often load or store a whole **word** (4 bytes) at once.

---

**Q:** In Nios V (Little Endian), which byte of a word has the same address as the word? Where is Word 1’s LSB?

**A:** The **least significant byte (LSB)** — bits 0–7 — has the **same address** as the word. So Word 0’s LSB is at address 0; **Word 1’s LSB** is at address **0x4** (one word = 4 bytes apart).

---

**Q:** What is Big Endian? Why does it matter that communicating processors agree?

**A:** **Big Endian** means the **most significant byte (MSB)** is stored at the **lowest** address (opposite of Little Endian). Processors that **talk to each other** must agree on which convention they use, or they will misinterpret multi-byte values.

---

## Code, data, and directives

**Q:** Where does the “code” (instructions) sit? Where does the “data” (e.g. variables) sit?

**A:** Both sit in **the same memory**. **Code** is in **consecutive** memory locations; **data** is also in that memory, often right after or near the code.

---

**Q:** How do you put constants like 10, 20, 30 into memory in assembly? What directive?

**A:** Use the **`.word`** directive: e.g. **`.word 10`**, **`.word 20`**, **`.word 30`**. Each reserves **one word (32 bits = 4 bytes)** and puts the constant there. (C analogy: like `int list[3] = {10, 20, 30};`.)

---

**Q:** What does a **label** (e.g. **list**) in front of a `.word` give you? Who figures out the actual address?

**A:** The label lets you **refer to that memory location by name** without hard-coding the address. The **assembler** figures out the actual address and substitutes it when you use the label. So the label is the **address** of that location.

---

**Q:** Why do we use a label instead of writing the address (e.g. 0x2c) directly?

**A:** The address **changes** if we add or remove instructions or data above it. The **assembler** keeps track; we just use the **symbol** (label) and the assembler plugs in the correct address.

---

**Q:** Does assembly have variable types like int, float, char?

**A:** **No.** We only have “how many bits” (byte, halfword, word) and whether we treat the bits as **signed** (2’s complement) or **unsigned**. The “type” is in the **programmer’s mind**.

---

## Load address, load word, store word

**Q:** What does **la t0, list** do?

**A:** **Load address.** It puts the **address** of the label **list** (e.g. 0x2c) into register **t0**. So **t0** holds a **pointer** to the first word of the list.

---

**Q:** What does **lw t1, (t0)** do? How is this like C?

**A:** **Load word.** It loads the **contents** of the memory location whose address is **in t0** into **t1**. So **t1 ← [t0]**. This is like **dereferencing a pointer** in C: **t1 = *ptr** where ptr is in t0.

---

**Q:** What does **lw t2, 4(t0)** do?

**A:** **Load word** from address **t0 + 4**. So **t2 ← [t0 + 4]** — the **second** word if t0 points to the first (words are 4 bytes apart).

---

**Q:** What does **sw t2, (t0)** do?

**A:** **Store word.** It writes the **contents of register t2** into the memory location whose address is **in t0**. So **[t0] ← t2**. Like ** *ptr = value** in C.

---

**Q:** Why can’t we do something like “add memory, memory” in one instruction?

**A:** The processor **only performs operations on registers**. We must **load** from memory into a register, do the operation, then **store** back to memory if needed.

---

## Example program (add three numbers)

**Q:** In the add-three-numbers program, after **la t0, list** and **lw t1, (t0)**, what is in t1?

**A:** The **first** number in the list — **10** (the contents of the memory word at the address in t0).

---

**Q:** After **lw t2, 4(t0)** and **lw t3, 8(t0)**, what are in t2 and t3?

**A:** **t2** = **20** (second word). **t3** = **30** (third word).

---

**Q:** After the two **add** instructions, where is the sum? What do we do with it?

**A:** The sum (**60**) is in **t2**. We then **la t0, answer** and **sw t2, (t0)** to **store** 60 into the memory location labeled **answer**.

---

## True/False

**Q:** T/F: In Nios V, the MSB of a word has the same address as the word.

**A:** **False.** In **Little Endian** (Nios V), the **LSB** has the same address as the word. The MSB is at the highest of the four byte addresses for that word.

---

**Q:** T/F: A label in assembly is a variable that holds a value.

**A:** **False.** A label is a **symbol for an address** — the address of a memory location. The assembler substitutes the numeric address when you use the label. It is like the **address of** a variable (a pointer), not the variable itself.

---

**Q:** T/F: **lw** loads the **address** of a label into a register.

**A:** **False.** **lw** **loads the contents** of a memory location (at the address given by the register, possibly with an offset) into a register. To load the **address** of a label we use **la** (load address).

---

End of practice. Use **L3_SUMMARY_MemoryOrganization.md** to review.
