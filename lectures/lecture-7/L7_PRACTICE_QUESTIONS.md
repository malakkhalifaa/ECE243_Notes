# ECE 243 Lecture 7 — Practice / Cheat-Sheet Questions (Subroutines)

---

## Short answer

1. **What does the program counter (`pc`) hold? Is it one of the 32 general-purpose registers (x0–x31)?**

2. **After a `call my_sub` instruction, what is in `ra`? What is in `pc`?**

3. **What does `ret` do (in terms of `pc` and `ra`)?**

4. **Why do we need to save `ra` before a subroutine makes another `call`?**

5. **What does “LIFO” mean in the context of the stack? Name the two main stack operations.**

6. **What does `.align 2` mean? (What boundary in bytes?)**

7. **Why can the program “crash” if we load a word from an address that is not 4-byte aligned?**

8. **In the lecture’s convention, which register is used to pass the first parameter to a subroutine? Which register is used for the return value?**

---

## True / False

9. **T / F** — `call` sets `pc` to the address of the subroutine and leaves `ra` unchanged.

10. **T / F** — If subroutine A calls subroutine B, and A does not save `ra` before the call, then when A later executes `ret`, it will not return to the correct place.

11. **T / F** — `.align 2` means “align to a 2-byte boundary.”

12. **T / F** — The stack is used so we can save and restore return addresses when subroutines call other subroutines.

---

## Trace execution

13. **Trace the following (assume `main` is at 0x1000, `next` at 0x1008, `my_sub` at 0x2000).**  
   Fill in `pc` and `ra` **after** the instruction runs (as you would see when about to execute the next instruction).

   ```
   main:   li   a0, 3      # pc = ? , ra = ?
           call my_sub     # pc = ? , ra = ?
   next:   li   a0, 4      # pc = ? , ra = ?
           ...
   my_sub: add  a0, a0, a0
           ret
   ```
   - Right after `call my_sub` (first time): `pc` = ? , `ra` = ?
   - Right after `ret`: `pc` = ? , `ra` = ?

14. **If `my_sub` did `call other` without saving `ra`, and `other` did `ret`, where would execution go? Where would `my_sub`’s `ret` eventually send execution? (Explain in one sentence each.)**

---

## Multiple choice (conceptual)

15. **The return address is stored in:**  
   (a) `pc`  
   (b) `ra`  
   (c) the stack  
   (d) `a0`

16. **`call` is like:**  
   (a) `j` (jump) only  
   (b) save next address in `ra`, then jump  
   (c) push `ra` on stack, then jump  
   (d) load `ra` from memory, then jump

17. **We use a stack (LIFO) for saving `ra` because:**  
   (a) it’s faster than memory  
   (b) subroutines can call subroutines; we need to restore the “right” return address in reverse order  
   (c) the processor only supports stack operations  
   (d) we don’t; we use a queue

---

## One-liner / exam-style

18. **Write the single instruction that “returns” from a subroutine (sets `pc` so execution goes back to the caller).**

19. **What two things does `call sub` do (in one short sentence each)?**

20. **Give one reason the lecture says we must save `ra` before calling another subroutine.**

---

## Answers (check after you try)

<details>  
<summary>Click to reveal answers</summary>

1. `pc` holds the address of the next instruction. No; `pc` is not one of x0–x31.  
2. `ra` = address of the instruction after `call`; `pc` = address of first instruction of `my_sub`.  
3. `ret` sets `pc ← ra` (jump back to the instruction after the `call`).  
4. The second `call` overwrites `ra`, so we’d lose the address to return to our own caller.  
5. Last In First Out. Push (add to top), Pop (remove from top).  
6. Align to 2² = 4-byte boundary.  
7. Processor may require word loads to be 4-byte aligned; unaligned load can fault/crash.  
8. Parameter: `a0`. Return value: `a0`.  
9. F (call also sets `ra` to next instruction).  
10. T.  
11. F (.align 2 = 4-byte boundary).  
12. T.  
13. After first `call my_sub`: pc = 0x2000, ra = 0x1008. After `ret`: pc = 0x1008, ra unchanged.  
14. After `other`’s `ret`: back to instruction after `call other` in `my_sub`. If `my_sub` didn’t save `ra`, `my_sub`’s `ret` uses the overwritten `ra` (from `call other`), so we’d “return” to the wrong place (e.g. inside `my_sub` again or to `other`’s caller).  
15. (b).  
16. (b).  
17. (b).  
18. `ret`  
19. (1) Put address of next instruction into `ra`. (2) Jump to subroutine (set `pc` to subroutine).  
20. Because that inner `call` overwrites `ra`, so we’d lose the address to return to our caller.

</details>
