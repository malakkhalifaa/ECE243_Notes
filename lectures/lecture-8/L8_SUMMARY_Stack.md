# ECE 243 Lecture #8 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 2 / Lab 3.
- **Last day:** Subroutines and introduction to the stack — **this is what you need for Lab 3**; today builds on it.
- **Today:** How the stack works in subroutines — the stack for subroutine **linkage**.

---

## Review (Lecture 7)
- The **return address** of a subroutine is placed into **`ra`** by the **`call`** instruction.
- For **subroutines that call other subroutines:** we **must push `ra` onto the stack** (and pop it back before our own `ret`), or we lose the address to return to our caller.
- The **push** and **pop** operations of the stack are written out below.

---

## The stack
- The stack is a **deeply fundamental** structure in a computer, used for many things.
- In **Nios V**, the stack is set up to **push and pop one or more words** (4 bytes each).
- A special register, **x2**, is designated as the **top-of-stack pointer**.
  - It **points to** (holds the **address of**) the **word on the top** of the stack.
  - We call it the **stack pointer** for short: **`sp`** (the name we use).
- We **must always initialize the stack pointer** at the beginning of any program that uses the stack.
- Stacks **grow downwards** (towards **smaller addresses**) in memory, so we **initialize `sp` in higher memory**.
  - In this course: initialize the stack pointer to **0x20000** — a memory location well above our program and data for the labs.
  - **When `sp` = 0x20000, the stack is empty** (there is nothing on it).

**Initialize the stack:**
```asm
la sp, 0x20000    # sp (x2) <- 0x20000
```

---

## Push (onto the stack)
To **push** a word-sized value onto the stack:
1. **Make room** for one word: subtract 4 from `sp` so `sp` points to the new “top” slot.
2. **Store** the word at that address.

**Example from lecture: push the (word-size) value 0x1234f678 onto the stack:**
```asm
li   t0, 0x1234f678    # (turned into two instructions to fit word)
# Stack is "empty," at the beginning, just after we initialized the sp.
# We want to make room for this first 4-byte item (1 word) on the stack,
# so we subtract 4 from the sp, to provide a place to put those 4 bytes:
addi sp, sp, -4        # sp <- sp - 4 = 0x20000 - 4 = 0x1FFFC
sw   t0, (sp)          # pushes the value in t0 (0x1234f678) onto the stack
                       # does not change t0 itself.
```
- **Push** = “put on top”: first **addi sp, sp, -4**, then **sw reg, (sp)**.

---

## Pop (off the stack)
To **pop** a word off the stack into a register:
1. **Load** the word at the current top (address in `sp`) into the register.
2. **Remove** the item from the stack by adding 4 to `sp` (so `sp` points to the word “under” the old top).
- If `sp` is back at **0x20000**, the stack is **empty**.
- Note: the **contents of memory** at the old top haven’t changed; we still say the item has been **removed from the stack** (the stack pointer has moved).

**Example from lecture: pop that item back off the stack into reg t1 (reverse order of push):**
```asm
lw   t1, (sp)      # this copies the value on the top of the stack into t1
                   # (e.g. given above, t1 <- 0x1234f678)
addi sp, sp, 4     # this removes the item from the stack, because the stack
                   # pointer is now pointing at the word under the stack.
                   # If the sp is back at 0x20000, then the stack is empty.
                   # Note: the contents of memory haven't changed; yet we do
                   # say that the item has been removed from the stack.
```
- **Pop** = “take off top”: first **lw reg, (sp)**, then **addi sp, sp, 4**. (Lecture sometimes writes "addi, sp, sp, 4" — the correct instruction is **addi sp, sp, 4** with no comma after addi.)

---

## LIFO
- **Push** (onto the stack) and **Pop** (off the stack) have **Last-In-First-Out** behaviour: the **last thing pushed** is the **first thing popped**.
- This is exactly what we want for storing **`ra`** and other values when using subroutines: the most recent call is returned from first, so we need to restore the most recently saved `ra` first — which is what pop gives us.

---

## Subroutines that call other subroutines: save/restore `ra`
**Rule:** Before a subroutine does **any** `call`, it must **push `ra`** onto the stack at the **very beginning**. Before it does **`ret`**, it must **pop `ra`** back from the stack.

**Pattern for each subroutine that might call another:**
```asm
my_sub:  addi sp, sp, -4    # first thing: make room for one word
         sw   ra, (sp)      # push ra onto stack (so we can call others and not lose it!)
         # ... body: can use call here ...
         lw   ra, (sp)       # pop top of stack back into ra, just before returning
         addi sp, sp, 4
         ret                 # now we return with the correct ra (pc <- ra)
```

---

## Example: main → sub_1 → sub_2 → sub_3
Program that calls a subroutine which itself calls another, which calls another (from the lecture):

```asm
         la   sp, 0x20000    # initialize stack pointer high in memory
         li   a0, 1
         call sub_1
done:    j    done

sub_1:   addi sp, sp, -4     # very first thing, push ra onto stack
         sw   ra, (sp)       # so can call other subroutines, and not lose it!
         # .....
         call sub_2          # go off to sub_2, then come back
         # .....
         lw   ra, (sp)       # pop top of stack into ra just before returning
         addi sp, sp, 4      # (lecture writes "addi, sp, sp, 4" — use addi sp, sp, 4)
         ret                 # can now return.

sub_2:   addi sp, sp, -4     # very first thing, push ra onto stack
         sw   ra, (sp)       # so can call other subroutines, and not lose it!
         # .....
         call sub_3          # go off to sub_3, then come back
         # .....
         lw   ra, (sp)       # pop top of stack into ra
         addi sp, sp, 4
         ret                 # can now return. (pc <- ra - the correct one!)

sub_3:   # would look similar: addi sp, sp, -4; sw ra, (sp); ... ; lw ra, (sp); addi sp, sp, 4; ret
```

---

## What the stack looks like at the beginning of sub_3 (lecture diagram)
**From the lecture:** "What would the stack look like right at the beginning of sub_3? Here:" (from **top of stack**, where **sp** points, down to **higher addresses**). Order of pushes: when we **enter sub_1** we push `ra` (return address to main). When we **enter sub_2** we push `ra` (return address to sub_1). When we **enter sub_3** we push `ra` (return address to sub_2). So at the **beginning of sub_3** (right after sub_3’s push), from **top (sp)** down to **higher addresses**:

| Position (top → bottom) | Lecture label |
|------------------------|----------------|
| ← **stack pointer would be here at the beginning of sub_3** | **sp** points here (top = most recent push) |
| ← pushed on stack at beginning of **sub_1** | (oldest: ra = return to main) |
| ← pushed on stack at beginning of **sub_3** | (ra = return to sub_2) |
| ← pushed on stack at beginning of **sub_2** | (ra = return to sub_1) |
| ← **stack pointer would be back here after sub_1 returns** | **sp** = 0x20000 (stack empty) |

So: **sp** points to the **top** (most recently pushed). The **last thing pushed** is the **first thing we will pop** when we return from sub_3, then sub_2, then sub_1 — which is exactly the right order (LIFO).

---

## Quick reference
| Item | Meaning |
|------|----------|
| **sp** (x2) | Stack pointer — points to (address of) the **word on top** of the stack. |
| **Stack empty** | When **sp = 0x20000** (in this course). |
| **Initialize** | `la sp, 0x20000` at start of any program that uses the stack. |
| **Stack grows** | **Downwards** (towards smaller addresses). |
| **Push** | `addi sp, sp, -4` then `sw reg, (sp)`. |
| **Pop** | `lw reg, (sp)` then `addi sp, sp, 4`. |
| **LIFO** | Last In, First Out — last pushed is first popped. |
| **Save ra** | At start of subroutine that calls another: `addi sp, sp, -4`; `sw ra, (sp)`. |
| **Restore ra** | Before `ret`: `lw ra, (sp)`; `addi sp, sp, 4`; then `ret`. |
