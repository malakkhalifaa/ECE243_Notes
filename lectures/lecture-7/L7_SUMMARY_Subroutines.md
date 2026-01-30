# ECE 243 Lecture 7 — Subroutines: Summary Sheet

## 1. What is a Subroutine?
- **Separate, reusable code** called from different places in a program.
- In C: *functions*, *procedures*, *methods*.
- **Why use them:** structure code, break tasks into pieces, reuse (APIs).

---

## 2. Two Questions Subroutines Must Solve
1. **Where to return?** (two different call sites → two different “go back” addresses.)
2. **How do parameters get in?** (e.g. `3` and `4` into `my_sub`’s `p`.)

In assembly we handle both explicitly.

---

## 3. Program Counter (`pc`)
- **Not** one of the 32 registers `x0`–`x31`.
- Holds the **address of the next instruction** to execute.
- After an instruction starts, `pc` is updated (e.g. `pc ← pc + 4` in Nios V) so the next instruction is fetched.
- **Why +4?** Each instruction is one word (4 bytes); instructions are stored in memory as numbers at word-aligned addresses.

---

## 4. Return Address Register (`ra` = `x1`)
- Holds the **address to return to** when the subroutine finishes.
- **Rule:** Before a subroutine that **calls another subroutine** runs, it must **save `ra`** (e.g. on the stack) and **restore it** before returning, or the original return address is lost.

---

## 5. The `call` Instruction
```
call my_sub    # subroutine label/address
```
**Effect:**
1. `ra ← pc`   (save address of the **next** instruction — where to return)
2. `pc ← my_sub`   (jump to first instruction of the subroutine)

So “return” later means: set `pc` back to the value we saved in `ra`.

---

## 6. The `ret` Instruction
```
ret
```
**Effect:** `pc ← ra`  
Execution continues at the instruction **after** the `call` that invoked this subroutine.

---

## 7. What Makes Code a “Subroutine”?
1. You **enter** it with a **`call`** (not a plain `j`).
2. It **exits** with **`ret`**.

---

## 8. Nested Subroutines (Subroutine Calls Another)
- A **second `call`** overwrites `ra` with the new “return after this call” address.
- The **first** return address (back to `main`) is **lost** if we don’t save it.
- **Rule:** Before a subroutine does **any** `call`, it must **save `ra`** (and restore it before its own `ret`).  
  Typically we save/restore **on the stack**.

---

## 9. The Stack (LIFO)
- **Last In, First Out** — like a stack of plates.
- **Push:** put an item on top.
- **Pop:** remove the top item.
- Used to save multiple return addresses (and other saved registers) when subroutines call subroutines.  
  We’ll see exact assembly (e.g. `addi sp, sp, -…`, `sw ra, 0(sp)`, etc.) in later lectures.

---

## 10. Parameter / Return Value (Convention in the Example)
- **Parameter:** passed in **`a0`** (e.g. `li a0, 3` before `call my_sub`).
- **Return value:** subroutine puts result in **`a0`** (e.g. `add a0, a0, a0`).

---

## 11. Assembler Directives (`.text`, `.data`, `.align`)
- **`.text`** — what follows is **code**.
- **`.data`** — what follows is **data** (e.g. labels for bytes/words).
- **`.align n`** — align **next** item to a **2^n** byte boundary.  
  - `.align 2` → align to **2² = 4 bytes** (word boundary).  
  - **Note:** `.align` is used in the **data** section; use **`.data`** so `.align` is valid.
- **`.byte`** — 1 byte. **`.word`** — 4 bytes.  
  Loading a **word** from an address that is not 4-byte aligned can **crash**; use `.align 2` before the word so the label is word-aligned.

---

## Quick Reference
| Item        | Meaning |
|------------|---------|
| `pc`       | Address of next instruction (not in r0–r31). |
| `ra` (x1)  | Return address (where to go after `ret`).     |
| `call L`   | `ra ← pc`, then `pc ← L`.                     |
| `ret`      | `pc ← ra`.                                   |
| Stack      | LIFO; save/restore `ra` when subroutines call subroutines. |
| `.align n` | Align to 2^n bytes (e.g. `.align 2` = 4-byte). |
