# Lecture 7 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #7**.

---

## Lecture context

**Q:** What does **Note 1** say about `.align`? What does **Note 2** say about `.align 2`?

**A:** **Note 1:** You must use the **`.data`** assembler directive for **`.align`** to work. **Note 2:** **`.align 2`** means align to **4-byte address / word boundaries** (power of 2: 2² = 4), not 2 bytes.

---

**Q:** In the C example with `my_sub(3)` and `my_sub(4)`, what two questions does the lecture say we must answer in assembly?

**A:** (1) How does the return statement know where to “go back to”? (Two different call sites → two different return addresses.) (2) How do the parameters (3, 4) get to `my_sub` and into variable `p`?

---

**Q:** In CPUlator, what does the program counter show? When does the processor do `pc ← pc + 4`?

**A:** The program counter shows the **address of the next instruction** that will be single-stepped (before that instruction executes). Very soon after execution of an instruction **begins**, the processor does **pc ← pc + 4**.

---

## pc, ra, call, ret

**Q:** What is the program counter (`pc`)? What does it hold? Is it one of the 32 registers (x0–x31)?

**A:** The **program counter** is a special processor register (not one of x0–x31). It holds the **address of the next instruction** to be executed. The processor fetches the instruction at that address, executes it, then typically does `pc ← pc + 4`. So `pc` is how the processor knows what to do next.

---

**Q:** Why does `pc` increment by 4 (not 1)?

**A:** Each instruction is **one word** (4 bytes) and is stored at word-aligned addresses (0x0, 0x4, 0x8, …). So the next instruction is always 4 bytes away. If `pc` went by 1, we’d point into the middle of an instruction.

---

**Q:** What is `ra`? Which register? What is it for?

**A:** **`ra`** = **return address** register; it is **x1**. It holds the **address to return to** when a subroutine finishes. `call` puts the address of the next instruction into `ra`; `ret` does `pc ← ra` so we go back there.

---

**Q:** After `call my_sub` runs, what is in `ra`? What is in `pc`?

**A:** **`ra`** = address of the **instruction after** the `call` (where we’ll return). **`pc`** = address of the **first instruction of `my_sub`** (execution has jumped into the subroutine).

---

**Q:** What does `ret` do? Why is that enough to return?

**A:** **`ret`** does **`pc ← ra`**. So execution continues at the instruction after the `call` that invoked this subroutine. The right address was saved in `ra` by `call`, so nothing else is needed.

---

**Q:** What two things make code a “subroutine”? (Lecture Q&A.)

**A:** (1) You **jump** to it with a **`call`** instruction. (2) It has a **`ret`** instruction. So: enter with `call`, exit with `ret`.

---

**Q:** Write the single instruction that returns from a subroutine.

**A:** **`ret`**

---

**Q:** In one short sentence each, what two things does `call sub` do?

**A:** (1) **`ra ← pc`** — save the address of the next instruction (return address) in `ra`. (2) **`pc ← sub`** — jump to the subroutine.

---

## Nested subroutines and stack

**Q:** Why must we save `ra` before a subroutine makes another `call`? What goes wrong if we don’t?

**A:** The second `call` **overwrites `ra`** with the “return from the inner subroutine” address. We **lose** the address that would take us back to *our* caller. When we later do `ret`, we’ll “return” to the wrong place. So we must save `ra` (e.g. on the stack) before the inner `call` and restore it before our own `ret`.

---

**Q:** What does “LIFO” mean? Name the two main stack operations.

**A:** **LIFO** = **Last In, First Out** (last item put on is the first taken off, like a stack of plates). **Push** — put an item on top. **Pop** — remove the top item. We use the stack to save/restore `ra` when subroutines call subroutines.

---

**Q:** In the lecture’s convention, which register passes the first parameter? Which holds the return value?

**A:** **First parameter:** **`a0`**. **Return value:** **`a0`**.

---

## .text, .data, .align

**Q:** What do `.text` and `.data` mean? Why do we need `.data` for `.align` to work?

**A:** **`.text`** = what follows is **code**. **`.data`** = what follows is **data** (e.g. `.byte`, `.word`). We need both so the assembler knows code vs data. The lecture says you **must** use **`.data`** for **`.align`** to work (Note 1).

---

**Q:** What does `.align 2` mean? What boundary in bytes (2^n)?

**A:** **`.align n`** = align the **next** item to a **2^n** byte boundary. So **`.align 2`** = **2² = 4 bytes** (word boundary), not 2 bytes.

---

**Q:** Why can the program crash if we use `lw` with an address that is not 4-byte aligned?

**A:** The processor typically **requires** the address for `lw` to be **4-byte aligned**. If the word is placed right after a byte without `.align 2`, its address might be 0x1001, etc., and `lw` can cause an **alignment fault** or crash. So we use `.align 2` before the word.

---

## True/False

**Q:** T/F: `call` sets `pc` to the subroutine and leaves `ra` unchanged.

**A:** **False.** `call` does **`ra ← pc`** (saves return address) and **`pc ← subroutine`** (jumps). So `ra` is **not** unchanged.

---

**Q:** T/F: If A calls B and A does not save `ra` before the call, then when A does `ret`, it will not return to the correct place.

**A:** **True.** The `call` to B overwrites `ra`, so the original return address (back to A’s caller) is lost. A’s `ret` then uses the wrong address.

---

**Q:** T/F: `.align 2` means “align to a 2-byte boundary.”

**A:** **False.** `.align 2` means align to a **2² = 4-byte** boundary.

---

**Q:** T/F: The stack is used to save and restore return addresses when subroutines call other subroutines.

**A:** **True.**

---

## Multiple choice

**Q:** When we execute `call my_sub`, where is the return address stored? (a) pc  (b) ra  (c) stack  (d) a0

**A:** **(b) ra.** `call` copies `pc` (address of next instruction) into `ra`. The stack is used when we *save* `ra` (e.g. before another `call`), but the place used for “where to return” is `ra`.

---

**Q:** What does `call sub` do? (a) Only jump to sub  (b) Save next address in ra, then jump  (c) Push ra on stack, then jump  (d) Load ra from memory, then jump

**A:** **(b)** Save the address of the next instruction in `ra`, then jump to `sub`.

---

**Q:** Why do we use a stack (LIFO) for saving `ra`? (a) Faster  (b) Subroutines call subroutines; we need to restore the right return address in reverse order  (c) Processor only supports stack  (d) We use a queue

**A:** **(b)** Subroutines can call subroutines; we need to restore return addresses in **reverse** order of the calls, which is exactly what LIFO (pop) gives.

---

## Trace execution

**Q:** Assume `_start` at 0x1000, `after1` at 0x1008, `after2` at 0x1010, `go` at 0x1020, `add_sub` at 0x2000. Fill in **pc** and **ra** *right after* each instruction executes.

```asm
_start:   li   a0, 2
         call add_sub
after1:  li   a0, 3
         call add_sub
after2:  j    go
add_sub: add  a0, a0, a0
         ret
```

| Instruction         | pc (after) | ra (after) |
|---------------------|------------|------------|
| call add_sub (1st)   | ?          | ?          |
| ret (1st)           | ?          | ?          |
| call add_sub (2nd)  | ?          | ?          |
| ret (2nd)           | ?          | ?          |

**A:**

| Instruction         | pc (after) | ra (after) |
|---------------------|------------|------------|
| call add_sub (1st)  | 0x2000     | 0x1008     |
| ret (1st)           | 0x1008     | (unchanged)|
| call add_sub (2nd)  | 0x2000     | 0x1010     |
| ret (2nd)           | 0x1010     | (unchanged)|

---

**Q:** If `my_sub` did `call other` without saving `ra`, and `other` did `ret`, where does execution go after `other`’s `ret`? Where would `my_sub`’s `ret` send execution?

**A:** After **`other`’s `ret`**: execution goes back to the instruction **after** `call other` inside `my_sub`. **`my_sub`’s `ret`**: because `ra` was overwritten by `call other`, `my_sub`’s `ret` uses that overwritten value, so we “return” to the **wrong** place (e.g. to the instruction after `call other` in `my_sub` again, or to `other`’s caller), not to whoever called `my_sub`.

---

## Fill in the blanks

**Q:** Complete so it calls `double_it` with parameter 5 and then loops forever. Return value in `a0`.

```asm
_start:  li   a0, ______
         call ______
stop:    j    stop
double_it: add a0, a0, a0
         ______
```

**A:** First blank: **5**. Second: **double_it**. Third: **ret**. So `li a0, 5` → `call double_it` → … → `double_it:` … `add a0, a0, a0` → `ret`.

---

**Q:** Fill in the missing directive so the next label is on a 4-byte boundary.

```asm
.data
mybyte:  .byte 0x11
______   # align to 4-byte boundary
myword:  .word 0xdeadbeef
```

**A:** **`.align 2`**

---

## Fix / find the bug

**Q:** This can crash. Fix with the minimum change (add the right directive).

```asm
.data
value:   .word 0x12345678
```

(Code: `la t0, value` then `lw t1, (t0)`.)

**A:** Add **`.align 2`** before `value` so the word is 4-byte aligned:

```asm
.data
.align 2
value:   .word 0x12345678
```

---

**Q:** Someone wrote this and said “when my_sub returns, it goes to the wrong place.” Why?

```asm
helper:  add  a0, a0, 1
         call my_sub
         ret
```

**A:** **`call my_sub`** overwrites **`ra`** with the address of the instruction after that `call` (the `ret` in `helper`). When `my_sub` does `ret`, we correctly return to `helper`. But when **`helper`** does **`ret`**, it uses that same `ra` (still pointing inside `helper`), **not** the address of whoever called `helper`. So we never return to the original caller. **Fix:** Save `ra` (e.g. on the stack) before `call my_sub` and restore it before `helper`’s `ret`.

---

**Q:** This should load the word at `data_word` into `t2`. What’s wrong?

```asm
.data
data_byte: .byte 0x55
data_word: .word 0x99aabbcc
```

(Code: `la t0, data_word` then `lw t2, (t0)`.)

**A:** **`data_word`** comes right after a **byte**, so it may not be **4-byte aligned**. **`lw`** can then fault. **Fix:** Put **`.align 2`** before `data_word`:

```asm
data_byte: .byte 0x55
.align 2
data_word: .word 0x99aabbcc
```

---

## Write the code

**Q:** Write a tiny program that: puts 7 in `a0`, calls a subroutine `triple` that does `a0 = a0 * 3` (e.g. using adds), then loops forever.

**A:** One way (using a temp for 3*a0):

```asm
.global _start
.text
_start:  li   a0, 7
         call triple
loop:    j    loop
triple:  add  t0, a0, a0    # t0 = 2*a0
         add  a0, t0, a0    # a0 = 3*a0
         ret
```

---

**Q:** Write a `.data` section that defines: a byte `b1` with value 0xAB, then a word `w1` with value 0x11223344, with the word 4-byte aligned.

**A:**

```asm
.data
b1:   .byte 0xAB
.align 2
w1:   .word 0x11223344
```

---

End of practice. Use **L7_SUMMARY_Subroutines.md** and the example `.s` files in this folder to review.
