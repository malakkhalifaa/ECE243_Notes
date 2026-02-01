# Lecture 7 — Practice Questions (Answers Under Each Question)

All questions are based on lecture content: subroutines, `pc`, `ra`, `call`, `ret`, stack, `.text`/`.data`/`.align`.

---

## 1. Lecture content: Program counter and registers

**Q:** What is the program counter (`pc`)? What does it hold? Is it one of the 32 general-purpose registers (x0–x31)?

**A:** The **program counter** is a special processor register (not one of x0–x31). It holds the **address of the next instruction** that will be executed. When an instruction runs, the processor fetches the instruction at the address in `pc`, executes it, and then typically updates `pc` to `pc + 4` so the next instruction (at the next word-aligned address) runs. So `pc` is how the processor “knows where to go next.” It is **not** in the set of 32 registers we use in assembly (x0–x31); it’s internal to the CPU.

---

## 2. Lecture content: Why pc increments by 4

**Q:** Why does the program counter increment by 4 (and not by 1) when going to the next instruction?

**A:** In RISC-V (and Nios V), each instruction is **one word** in size. A word is **4 bytes**. Instructions are stored in memory at **word-aligned** addresses (0x0, 0x4, 0x8, …). So the “next” instruction is always 4 bytes (one word) after the current one. Therefore `pc` is updated by 4, not 1. (If it went by 1, we’d be pointing into the middle of an instruction.)

---

## 3. Lecture content: Return address register

**Q:** What is `ra`? Which register number is it? What is it used for?

**A:** **`ra`** is the **return address** register. It is **x1**. It is used to hold the **address to return to** when a subroutine finishes. When we use `call sub`, the processor puts the address of the **next** instruction (the one after `call`) into `ra`. When the subroutine executes `ret`, it sets `pc ← ra`, so execution goes back to that “next” instruction. So `ra` answers the question: “Where do I go back to after this subroutine?”

---

## 4. Lecture content: The call instruction

**Q:** After a `call my_sub` instruction runs, what is in `ra`? What is in `pc`? Explain in one sentence each.

**A:**  
- **`ra`:** The address of the **instruction right after** the `call` (the “next” instruction in the caller). That is where we will return when the subroutine does `ret`.  
- **`pc`:** The address of the **first instruction of `my_sub`**. So execution has “jumped” into the subroutine.  
So `call` does two things: (1) save “where to return” in `ra`, and (2) jump to the subroutine by setting `pc` to the subroutine’s address.

---

## 5. Lecture content: The ret instruction

**Q:** What does `ret` do in terms of `pc` and `ra`? Why is that enough to “return” from a subroutine?

**A:** **`ret`** does: **`pc ← ra`**. So the processor sets the program counter to the value in `ra`. That value is the address of the instruction **after** the `call` that invoked this subroutine. So execution continues in the caller, right after the `call`. We don’t need to do anything else for a simple return: the right “go back” address was saved in `ra` by `call`, and `ret` just uses it.

---

## 6. Lecture content: What makes code a subroutine?

**Q:** What two things make a piece of code a “subroutine” (how we enter it and how we leave it)?

**A:**  
1. **Enter** with **`call`** (not a plain `j`). Using `call` saves the return address in `ra` and then jumps.  
2. **Leave** with **`ret`**. That sets `pc ← ra` so we go back to the instruction after the `call`.  
If we used `j` to enter, we wouldn’t save a return address, so we wouldn’t know where to return to. So “subroutine” means: entered by `call`, exited by `ret`.

---

## 7. Lecture content: Nested subroutines and ra

**Q:** Why must we save `ra` before a subroutine makes another `call`? What goes wrong if we don’t?

**A:** When our subroutine does **`call other`**, that **second** `call` will **overwrite `ra`**. The processor will put the “return-from-`other`” address (back to our subroutine) into `ra`. So we **lose** the original return address (the one that would take us back to *our* caller). When we later do `ret`, we’ll set `pc` to that new value and “return” to the wrong place (e.g. to the instruction after `call other` inside our subroutine, or worse). So before any `call` inside a subroutine, we must **save `ra`** (e.g. on the stack) and **restore it** before our own `ret`, so that when we `ret`, we go back to whoever called us.

---

## 8. Lecture content: The stack (LIFO)

**Q:** What does “LIFO” mean in the context of the stack? Name the two main stack operations and what they do.

**A:** **LIFO** = **Last In, First Out**. The last item we put on the stack is the first one we take off (like a stack of plates).  
The two main operations are:  
1. **Push** — put an item on top of the stack.  
2. **Pop** — remove the top item from the stack.  
We use the stack to save and restore `ra` (and other registers) when subroutines call subroutines. The LIFO order matches the order of calls and returns: the most recent call is returned from first, so we need to restore the most recently saved return address first — which is exactly what “pop” gives us.

---

## 9. Lecture content: Parameters and return value

**Q:** In the lecture’s convention, which register is used to pass the first parameter to a subroutine? Which register is used for the return value?

**A:**  
- **First parameter:** **`a0`**. The caller puts the value in `a0` before `call`; the subroutine uses `a0` as its input (e.g. the “p” in the C example).  
- **Return value:** **`a0`**. The subroutine puts the result in `a0` before `ret`; the caller can then read the result from `a0` after the call.  
So in the lecture example, `li a0, 3` then `call my_sub` passes 3; `my_sub` does `add a0, a0, a0` and returns with the result (6) in `a0`.

---

## 10. Lecture content: .text and .data

**Q:** What do the assembler directives `.text` and `.data` mean? Why do we need both?

**A:**  
- **`.text`** tells the assembler that what follows is **code** (instructions). So labels and instructions go in the code section.  
- **`.data`** tells the assembler that what follows is **data** (e.g. bytes, words). So we use `.byte`, `.word`, and labels for data in the data section.  
We need both so the assembler (and the system) know which parts of the program are executable code and which are data. Code and data are often placed in different regions of memory. Also, **`.align`** is used in the data section; the lecture notes say we need the **`.data`** directive for `.align` to work properly.

---

## 11. Lecture content: .align

**Q:** What does `.align 2` mean? What boundary in bytes is that (give the formula 2^n)?

**A:** **`.align n`** means: align the **next** label/item to a **2^n** byte boundary. So **`.align 2`** means align to a **2² = 4 byte** boundary (word boundary). It does **not** mean “align to 2 bytes.” So after `.align 2`, the next label will be at an address that is a multiple of 4 (e.g. 0x0, 0x4, 0x8, …). We use this before a `.word` so that the word is 4-byte aligned, which is required for `lw` to work without faulting.

---

## 12. Lecture content: Why alignment matters for lw

**Q:** Why can the program crash if we load a word with `lw` from an address that is not 4-byte aligned?

**A:** The processor typically **requires** that the address given to `lw` (load word) is **4-byte aligned** (i.e. the address is a multiple of 4). If we put a `.word` right after a `.byte` without `.align 2`, that word might end up at an address like 0x1001 or 0x1002. When we execute `lw` with such an address, the hardware may raise an **alignment fault** or **exception**, and the program can crash or behave incorrectly. So we use `.align 2` before the word so its address is a multiple of 4.

---

## 13. True/False — call and ra

**Q:** True or False: `call` sets `pc` to the address of the subroutine and leaves `ra` unchanged.

**A:** **False.** `call` does **two** things: (1) **`ra ← pc`** (it saves the address of the next instruction in `ra`), and (2) **`pc ← subroutine_address`** (it jumps to the subroutine). So `ra` is **not** left unchanged; it is set to the return address. If `ra` were unchanged, we would have no way to return correctly.

---

## 14. True/False — Nested calls

**Q:** True or False: If subroutine A calls subroutine B, and A does not save `ra` before the call, then when A later executes `ret`, it will not return to the correct place.

**A:** **True.** The `call` to B overwrites `ra` with the address of the instruction after that `call` (inside A). So the original return address (back to whoever called A) is lost. When A later does `ret`, it will set `pc` to that overwritten value and “return” to the wrong place (inside A, not to A’s caller). So A must save `ra` before calling B and restore it before its own `ret`.

---

## 15. True/False — .align 2

**Q:** True or False: `.align 2` means “align to a 2-byte boundary.”

**A:** **False.** `.align n` means align to a **2^n** byte boundary. So `.align 2` means align to **2² = 4 bytes**, not 2 bytes. So the next label will be at an address that is a multiple of 4 (word boundary).

---

## 16. Multiple choice — Where is the return address?

**Q:** When we execute `call my_sub`, where is the return address (the address we will go back to after `ret`) stored?  
(a) In `pc`  
(b) In `ra`  
(c) On the stack  
(d) In `a0`

**A:** **(b) In `ra`.** The `call` instruction copies `pc` (which at that moment is the address of the next instruction) into `ra`. So the return address is held in `ra`. The stack is used when we *save* `ra` (e.g. when a subroutine calls another subroutine), but the place the processor *uses* for “where to return” is `ra`. So (b) is correct.

---

## 17. Multiple choice — What does call do?

**Q:** What does `call sub` do?  
(a) Only jumps to `sub` (like `j sub`)  
(b) Saves the address of the next instruction in `ra`, then jumps to `sub`  
(c) Pushes `ra` on the stack, then jumps to `sub`  
(d) Loads `ra` from memory, then jumps to `sub`

**A:** **(b) Saves the address of the next instruction in `ra`, then jumps to `sub`.** So: first `ra ← pc` (save return address), then `pc ← sub` (jump). It does not push on the stack (we do that ourselves when we need to save `ra` before another `call`). So (b) is correct.

---

## 18. Trace: pc and ra after call and ret

**Q:** Assume: `_start` at 0x1000, `next` at 0x1008, `my_sub` at 0x2000. Right after the first `call my_sub` runs, what are `pc` and `ra`? Right after the first `ret` runs, what are `pc` and `ra`?

**A:**  
- **Right after `call my_sub` (first time):**  
  - **`pc`** = 0x2000 (first instruction of `my_sub`).  
  - **`ra`** = 0x1008 (address of `next`, the instruction after the `call`).  
- **Right after `ret`:**  
  - **`pc`** = 0x1008 (we set `pc ← ra`, so we’re at `next`).  
  - **`ra`** = still 0x1008 (unchanged; `ret` only changes `pc`).

---

## 19. Fill in the blanks — Small call/ret program

**Q:** Complete the program so it calls `double_it` with parameter 5 and then loops forever. Return value in `a0`.

```asm
_start:  li   a0, ______
         call ______
stop:    j    stop
double_it: add a0, a0, a0
         ______
```

**A:**  
- First blank: **5** (the parameter).  
- Second blank: **double_it** (the subroutine label).  
- Third blank: **ret** (return to caller).  
So: `li a0, 5` → `call double_it` → … → `double_it:` … `add a0, a0, a0` → `ret`.

---

## 20. Fix the program — .align for word load

**Q:** This program is supposed to load the word at `value` into `t1`. It can crash. Fix it with the minimum change (add the right directive).

```asm
.data
value:   .word 0x12345678
```

(Code: `la t0, value` then `lw t1, (t0)`.)

**A:** The problem is that `value` might not be 4-byte aligned (e.g. if there was something before it). We need to **align the word to a 4-byte boundary**. Add **`.align 2`** before `value`:

```asm
.data
.align 2
value:   .word 0x12345678
```

Then `value` will be at an address that is a multiple of 4, and `lw` will not fault.

---

## 21. Find the bug — ra overwritten

**Q:** Someone wrote this and said “when my_sub returns, it goes to the wrong place.” Why?

```asm
helper:  add  a0, a0, 1
         call my_sub
         ret
```

**A:** **`helper`** calls **`my_sub`**. The **`call my_sub`** overwrites **`ra`** with the address of the instruction after that `call` (i.e. the `ret` in `helper`). So when `my_sub` does `ret`, we correctly come back to `helper`’s `ret`. But when **`helper`** then does **`ret`**, it uses the **current** `ra` — which still holds the address of the instruction after `call my_sub` (inside `helper`), **not** the address of whoever called `helper`. So we never return to the original caller; we “return” to the wrong place. The fix: **save `ra`** (e.g. on the stack) before `call my_sub`, and **restore `ra`** before `helper`’s `ret`, so that `helper`’s `ret` uses the correct return address.

---

## 22. Find the bug — Alignment for data_word

**Q:** This is supposed to load the word at `data_word` into `t2`. What’s wrong?

```asm
.data
data_byte: .byte 0x55
data_word: .word 0x99aabbcc
```

(Code: `la t0, data_word` then `lw t2, (t0)`.)

**A:** **`data_word`** comes right after a **byte** (`data_byte`). So its address might be one byte after a 4-byte boundary (e.g. 0x1001), i.e. **not 4-byte aligned**. **`lw`** requires a 4-byte-aligned address; otherwise the program can fault. **Fix:** Put **`.align 2`** before `data_word` so it sits on a 4-byte boundary:

```asm
data_byte: .byte 0x55
.align 2
data_word: .word 0x99aabbcc
```

---

## 23. One-liner — Return instruction

**Q:** Write the single instruction that “returns” from a subroutine (so execution goes back to the caller).

**A:** **`ret`**. It does `pc ← ra`, so execution continues at the instruction after the `call` that invoked this subroutine.

---

## 24. One-liner — Two things call does

**Q:** In one short sentence each, what two things does `call sub` do?

**A:**  
1. **`ra ← pc`** — Save the address of the next instruction (the return address) in `ra`.  
2. **`pc ← sub`** — Jump to the subroutine by setting the program counter to the subroutine’s address.

---

That’s the end of the practice set. Use **L7_SUMMARY_Subroutines.md** and the example `.s` files in this folder to review any topic.
