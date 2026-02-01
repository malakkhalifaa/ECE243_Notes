# Lecture 8 — All Practice (One File, Answer Under Each Question)

No repetition. Every question has its answer directly below it. Based on **ECE 243 Lecture #8**.

---

## Lecture context

**Q:** What does “last day” cover? What does “today” cover in Lecture 8?

**A:** **Last day:** Subroutines and introduction to the stack (needed for Lab 3). **Today:** How the stack works in subroutines — the stack for subroutine **linkage**.

---

**Q:** From Lecture 7, why must we push `ra` onto the stack if a subroutine calls another subroutine?

**A:** The **`call`** to the other subroutine **overwrites `ra`** with the return address back to us. We **lose** the address that would take us back to *our* caller. So we **push `ra`** at the start (before any `call`) and **pop `ra`** before our own `ret`, so we still have the correct return address when we return.

---

## Stack pointer and initialization

**Q:** Which register is the stack pointer? What does it point to?

**A:** **x2** is the **stack pointer** (**`sp`**). It **points to** (holds the **address of**) the **word on the top** of the stack.

---

**Q:** Must we initialize the stack pointer? When? To what value in this course?

**A:** **Yes.** We must **always initialize `sp`** at the **beginning** of any program that uses the stack. In this course we initialize it to **0x20000** (a memory location well above our program and data for the labs).

---

**Q:** Why do we initialize `sp` in “higher” memory? Which way does the stack grow?

**A:** The stack **grows downwards** (towards **smaller addresses**) in memory. So we **initialize `sp` in higher memory** so there is room “below” (at smaller addresses) for the stack to grow.

---

**Q:** When is the stack “empty” in this course? What instruction do we use to initialize `sp`?

**A:** The stack is **empty** when **`sp` = 0x20000**. We use **`la sp, 0x20000`** (or equivalent) so **sp (x2) ← 0x20000**.

---

## Push and pop (operations)

**Q:** Write the two instructions to **push** the value in register `t0` onto the stack (in order). What does each do?

**A:**  
1. **`addi sp, sp, -4`** — make room for one word: `sp` points to the new top (4 bytes lower).  
2. **`sw t0, (sp)`** — store the word in `t0` at the address in `sp` (pushes the value onto the stack; does not change `t0`).

---

**Q:** Write the two instructions to **pop** the top of the stack into register `t1` (in order). What does each do?

**A:**  
1. **`lw t1, (sp)`** — load the word at the address in `sp` (the top of the stack) into `t1`.  
2. **`addi sp, sp, 4`** — remove the item from the stack by moving `sp` up by 4 bytes (so it points to the word below; if `sp` = 0x20000, the stack is empty).

---

**Q:** When we “pop” an item off the stack, do the contents of memory at the old top change? Why do we still say the item was “removed”?

**A:** The **contents of memory** at the old top **do not change**. We say the item has been **removed from the stack** because the **stack pointer** has moved (we moved `sp` up by 4), so that word is no longer “on” the stack (we no longer consider it part of the stack).

---

**Q:** What does “LIFO” mean for the stack? Why is that what we want for saving `ra` when subroutines call subroutines?

**A:** **LIFO** = **Last In, First Out** — the **last thing pushed** is the **first thing popped**. When subroutines call subroutines, we return from the **most recent** call first, so we need to **restore** the most recently saved `ra` first. That is exactly the order we get when we **pop** (LIFO).

---

## Save and restore ra in subroutines

**Q:** What must a subroutine do at the **very beginning** if it might call another subroutine? What must it do **just before** `ret`?

**A:** At the **very beginning:** **push `ra`** onto the stack: `addi sp, sp, -4` then `sw ra, (sp)`. **Just before `ret`:** **pop `ra`** from the stack: `lw ra, (sp)` then `addi sp, sp, 4`, then `ret`.

---

**Q:** In the lecture’s pattern, why do we push `ra` “so we can call other subroutines and not lose it”?

**A:** When we **`call`** another subroutine, that **`call`** overwrites **`ra`** with the return address back to us. If we hadn’t saved our own return address (the one that takes us back to *our* caller) on the stack, we would **lose** it. Pushing `ra` at the start lets us **restore** it before our own `ret`, so we return to the correct place.

---

## True/False

**Q:** T/F: When `sp` = 0x20000, the stack is empty.

**A:** **True.** In this course, the stack is empty when `sp` = 0x20000.

---

**Q:** T/F: To push a word onto the stack, we first do `addi sp, sp, 4`, then `sw`.

**A:** **False.** To **push**, we first do **`addi sp, sp, -4`** (make room by moving `sp` **down**), then **`sw`**. We **subtract** 4 because the stack grows downwards.

---

**Q:** T/F: To pop a word off the stack, we first do `lw`, then `addi sp, sp, 4`.

**A:** **True.** First **`lw reg, (sp)`** (copy the value at the top into the register), then **`addi sp, sp, 4`** (move `sp` up so the item is “removed” from the stack).

---

**Q:** T/F: The stack grows towards higher addresses in memory.

**A:** **False.** The stack **grows downwards** (towards **smaller** addresses). So we initialize `sp` in higher memory and subtract 4 when we push.

---

**Q:** T/F: A subroutine that calls another subroutine must push `ra` at the start and pop it back before `ret`.

**A:** **True.** Otherwise the inner `call` overwrites `ra` and we lose the address to return to our caller.

---

## Multiple choice

**Q:** Which register is the stack pointer? (a) x0  (b) x1  (c) x2  (d) pc

**A:** **(c) x2.** We call it **`sp`**. It points to the word on the top of the stack.

---

**Q:** To push one word onto the stack, we: (a) add 4 to sp, then sw  (b) subtract 4 from sp, then sw  (c) lw then add 4 to sp  (d) sw then add 4 to sp

**A:** **(b)** **Subtract 4 from sp** (`addi sp, sp, -4`), **then** **`sw`** the value at `(sp)`.

---

**Q:** When we pop, we do: (a) addi sp, sp, -4 then lw  (b) lw then addi sp, sp, 4  (c) sw then addi sp, sp, 4  (d) addi sp, sp, 4 then lw

**A:** **(b)** **`lw reg, (sp)`** (load from top), **then** **`addi sp, sp, 4`** (move sp up, “remove” the item).

---

## Trace / stack picture

**Q:** Main calls sub_1, sub_1 calls sub_2, sub_2 calls sub_3. Each subroutine pushes `ra` at the start and pops before `ret`. At the **beginning of sub_3** (right after sub_3 has done its push), what is on the stack from **top (sp)** down? List the three saved values (whose return address each is).

**A:** From **top (sp)** down:  
1. **Word pushed at beginning of sub_3** — `ra` (return address to sub_2).  
2. **Word pushed at beginning of sub_2** — `ra` (return address to sub_1).  
3. **Word pushed at beginning of sub_1** — `ra` (return address to main).  
Below that, `sp` would be back at 0x20000 after all have returned (stack empty).

---

**Q:** In the same program (main → sub_1 → sub_2 → sub_3), when sub_3 does `ret`, where does execution go? When sub_2 then does `ret`, where does it go? Why does popping `ra` give the right order?

**A:** When **sub_3** does `ret`: we have just popped `ra` (the address we saved when we entered sub_3), which is the **return address to sub_2** (instruction after `call sub_3` in sub_2). So execution goes **back to sub_2**. When **sub_2** then does `ret`: we popped the `ra` we saved when we entered sub_2, which is the **return address to sub_1**. So execution goes **back to sub_1**. Popping gives the **right order** because we **pushed** in order (sub_1, then sub_2, then sub_3), and **LIFO** means we **pop** in reverse order (sub_3’s ra, then sub_2’s, then sub_1’s) — which is exactly the order we return (sub_3 → sub_2 → sub_1 → main).

---

## Fill in the blanks

**Q:** Complete the push of `ra` onto the stack (two instructions):

```asm
addi sp, sp, ______
sw   ______, (sp)
```

**A:** First blank: **-4**. Second blank: **ra**. So: `addi sp, sp, -4` then `sw ra, (sp)`.

---

**Q:** Complete the pop of the stack into `ra` before returning (two instructions, then `ret`):

```asm
lw   ra, (sp)
addi sp, sp, ______
ret
```

**A:** Blank: **4**. So: `lw ra, (sp)` then `addi sp, sp, 4` then `ret`.

---

**Q:** Initialize the stack pointer so the stack is empty and ready to use (one instruction; use 0x20000).

**A:** **`la sp, 0x20000`** (or equivalent so **sp ← 0x20000**).

---

## Fix / find the bug

**Q:** Someone wrote this subroutine that calls another. It sometimes returns to the wrong place. What’s wrong?

```asm
bad_sub: call other
         lw   ra, (sp)
         addi sp, sp, 4
         ret
```

**A:** We **never pushed `ra`** before `call other`. The `call other` **overwrote `ra`** with the return address back to us, so we **lost** the address that would take us back to *our* caller. The **fix:** at the **very beginning** of the subroutine, **push `ra`**: `addi sp, sp, -4` then `sw ra, (sp)`. Then the pop before `ret` will restore the correct `ra`.

---

**Q:** Someone wrote this. After the subroutine returns, the program crashes or behaves wrongly. Why?

```asm
bad_sub: addi sp, sp, -4
         sw   ra, (sp)
         call other
         addi sp, sp, 4
         lw   ra, (sp)
         ret
```

**A:** The **order of pop is wrong**. We must **first** load `ra` from the stack, **then** add 4 to `sp`. Here we did **`addi sp, sp, 4`** before **`lw ra, (sp)`**, so we moved `sp` up **before** loading `ra`. So we loaded `ra` from the **wrong** address (the word that was “below” our saved `ra`), and we left the saved `ra` still “on” the stack. **Correct order:** `lw ra, (sp)` then `addi sp, sp, 4` then `ret`.

---

## Write the code

**Q:** Write the **push** of the value in `a0` onto the stack (two instructions).

**A:**
```asm
addi sp, sp, -4
sw   a0, (sp)
```

---

**Q:** Write the **pop** of the top of the stack into `t2` (two instructions).

**A:**
```asm
lw   t2, (sp)
addi sp, sp, 4
```

---

**Q:** Write the **prologue** (first two instructions) of a subroutine that will call another subroutine: push `ra` so we don’t lose it.

**A:**
```asm
addi sp, sp, -4
sw   ra, (sp)
```

---

**Q:** Write the **epilogue** (last three instructions) of that subroutine: pop `ra` and return.

**A:**
```asm
lw   ra, (sp)
addi sp, sp, 4
ret
```

---

End of practice. Use **L8_SUMMARY_Stack.md** in this folder to review.
