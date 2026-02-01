# ECE 243 Lecture #7 — Summary Sheet

## Lecture context
- **Work-in-flight:** Lab 2 this week / Lab 3 next (posted Wednesday).
- **Last day:** General form of move, add, subtract, load; logic and shift instructions (needed for Lab 3).
  - **Note 1:** You must use the **`.data`** assembler directive for **`.align`** to work (see example 7-4).
  - **Note 2:** **`.align 2`** means align to **4-byte address / word boundaries** (power of 2: 2² = 4).
- **Today:** Subroutines: subroutine linkage, parameter passing, and introduction to the stack.

---

## 1. What is a Subroutine?
- A **subroutine** is **separate code that is re-used at different points** in a program.
- In C, C++, etc. they are called **functions**, **procedures**, or **methods**.
- **Why use them:**
  - Key to **well-structured code**; lets you **break software into pieces** — which is how all engineering is done.
  - Lets **your software be reused** by others, and **someone else’s software** (APIs) be available to you.

---

## 2. Two Questions Subroutines Must Solve (from the C example)
We use this C code to see what assembly must do:

```c
int main(void) {
    int x, z;
    x = my_sub(3);
    z = my_sub(4);
}
int my_sub(int p) {
    return (p + p);
}
```

Two questions we must answer in assembly:
1. **How does the return statement know where to “go back to”?** — There are **two different places** `my_sub` was called from, so we need two different “go back” addresses.
2. **How do the parameters (3, 4) get to `my_sub` and into variable `p`?**

In C you don’t think about this; in assembly we handle both explicitly.

---

## 3. Program Counter (`pc`)
- **`pc`** = **program counter** (you see it at the top of the register list in CPUlator).
- The **`pc`** holds the **address of the next instruction to be executed**, after the current one.
- It is a **counter**; in **Nios V** it **increments by 4** (not 1) right **after** the current instruction **begins** executing.
- It is how the processor knows **what instruction to execute next** — usually the one at `pc+4`, but not if we’re executing a branch/jump.
- **`pc` is NOT one of the 32 registers (x0–x31).**

To make sense of this, remember:
- Each instruction (e.g. `li a0, 3`) is **encoded into a number** (e.g. `00300513`).
- That number is **stored at an address in memory** (e.g. 0x0).
- When execution begins, the processor **fetches** the instruction at that address, **executes** it by interpreting the number, then goes to the **next** instruction (e.g. at 0x4), and so on.

So instructions are at addresses 0x0, 0x4, 0x8, … — one **word** (4 bytes) per instruction — hence **pc** increments by **4**.

---

## 4. Return Address Register (`ra` = x1)
- **Register x1** is special for subroutines; it has the name **`ra`** = **“return address”** register.
- It holds the **“address to go back to”** after a called subroutine finishes.

---

## 5. Assembly Example: C Code → Lecture’s Assembly
Same behaviour as the C code above:

```asm
main:   li   a0, 3           # a0 <- 3  (parameter to the function; put in reg)
        call my_sub          # ra <- pc  (copy address of next instruction into ra)
                             # pc <- my_sub  (address of first instruction of subroutine;
                             #               setting pc to that takes execution there!)
                             # (return value comes back in a0; code doesn't use it here but could)
next:   li   a0, 4           # a0 <- 4  (parameter for the next call to my_sub)
        call my_sub          # as above: ra <- pc; pc <- my_sub  (pc is different here, so ra is set differently)
done:   j    done            # program "stops" in infinite loop

my_sub: add  a0, a0, a0      # a0 <- a0 + a0
        ret                  # 'return': pc <- ra
                             # ra was set to the next instruction after each call,
                             # so after ret: first time -> next; second time -> done
```

- **Parameter:** put in **`a0`** before `call`.
- **Return value:** subroutine leaves result in **`a0`**.

---

## 6. CPUlator Note
- In CPUlator, the **program counter** shows the **address of the next instruction** that will be single-stepped (i.e. **before** that instruction executes).
- **Very soon after** execution of an instruction begins, the processor does **pc ← pc + 4**.

You can demonstrate this program in CPUlator and watch **pc** and **ra** behave as above.

---

## 7. What Makes `my_sub` a Subroutine? (Lecture Q&A)
1. You **jump** to it with a **`call`** instruction (not a plain `j`).
2. It has a **`ret`** instruction.

So: **enter with `call`**, **exit with `ret`**.

---

## 8. The `call` Instruction
- **Effect:**
  1. **`ra ← pc`** — save the address of the **next** instruction (where to return).
  2. **`pc ← my_sub`** (or whatever label) — jump to the first instruction of the subroutine.

So “return” later means: set **pc** back to the value we saved in **ra**.

---

## 9. The `ret` Instruction
- **Effect:** **`pc ← ra`**
- Execution continues at the instruction **after** the `call` that invoked this subroutine.

---

## 10. Nested Subroutines: Why We Must Save `ra`
- If **your subroutine calls another subroutine**, that **second `call` will overwrite `ra`**.
- So the **return address that was sent to you** (to go back to your caller) **will be lost**.
- **Rule:** Before **any** subroutine makes a **call to another subroutine**, it must **save** the contents of **`ra`** before that call, and **restore** it when the subroutine returns.

Where should we store `ra`?
- In **another register?** No — you’ll run out of registers when calls nest deeply.
- In **memory?** Yes — but we need a **fixed rule** for where and in what order, because subroutines can call subroutines which call others, and we must get each return address back **at exactly the right time**.
- For that we use a **“last in, first out”** data structure: the **stack**.

---

## 11. The Stack (LIFO)
- **LIFO** = **Last In, First Out** — like a **stack of plates**: the last plate you put on top is the first one you take off.
- Two operations:
  1. **Push** — push an item onto the stack (e.g. one or more “plates”).
  2. **Pop** — pop an item off the stack (take the top item).

Next (in later lectures): how the stack is used in assembly (e.g. where to store `ra`, push/pop in code).

---

## 12. Example: Proper Use of `.text`, `.data`, and `.align`
From the lecture (7-4):

```asm
.global _start
.text              # tells assembler what follows is code, not data
_start: la t0, myword
        lw  t1, (t0)
        ...
done:   j   done

.data
mybyte: .byte 0x2a
.align 2           # align to 2**2 = 4 boundary (not 2!)
myword: .word 0x1a54dd33
```

- **The above code will crash without the `.align 2` statement** (e.g. if `myword` is not 4-byte aligned, `lw` can fault).
- **`.align n`** means align the **next** item to a **2^n** byte boundary. (Previously stated wrong in course — correct is: **power of 2**, so `.align 2` → **4-byte** boundary.)

**Notes from lecture:**
- **Note 1:** You must use the **`.data`** directive for **`.align`** to work.
- **Note 2:** **`.align 2`** = align to **4-byte address / word boundaries** (2² = 4).

---

## Quick Reference
| Item        | Meaning |
|------------|---------|
| **pc**     | Address of next instruction; not in x0–x31; increments by 4 after each instruction (except branch/jump). |
| **ra** (x1)| Return address — where to go after `ret`. |
| **call L**| `ra ← pc`, then `pc ← L`. |
| **ret**    | `pc ← ra`. |
| **Subroutine** | Enter with `call`, exit with `ret`. |
| **Nested call** | Save `ra` before calling another subroutine; restore before your `ret`. |
| **Stack**  | LIFO; push/pop; used to save/restore `ra` (and more) when subroutines call subroutines. |
| **.text**  | What follows is code. |
| **.data**  | What follows is data; **required for `.align` to work**. |
| **.align n** | Align next item to **2^n** byte boundary. **.align 2** = 4-byte (word) boundary. |
