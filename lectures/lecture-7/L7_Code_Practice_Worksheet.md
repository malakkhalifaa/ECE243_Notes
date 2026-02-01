# Lecture 7 — Code Practice (Examples Rewritten as Questions)

Use your lecture examples as reference. Try these without looking at the solutions first.

---

## Part A: Fill in the blanks (call / ret)

**1.** Complete the program so it calls `double_it` with parameter 5 and then loops forever. Assume the return value is in `a0`.

```asm
.global _start
.text
_start:
    li   a0, ______      # parameter 5
    call ______         # call subroutine
stop:
    j    stop

double_it:
    add  a0, a0, a0     # a0 = a0 + a0
    ______              # return to caller
```

**2.** What does `call double_it` do? (Two steps, in order.)
- Step 1: _______________________
- Step 2: _______________________

**3.** What does `ret` do? (One short line.)
- _______________________

---

## Part B: Trace execution (call / ret)

**4.** Assume addresses: `_start` at 0x1000, `after1` at 0x1008, `after2` at 0x1010, `go` at 0x1020, `add_sub` at 0x2000.

Fill in **pc** and **ra** *right after* the instruction executes (i.e. when about to run the *next* instruction).

| Instruction        | pc (after) | ra (after) |
|--------------------|------------|------------|
| `call add_sub` (first time) | _______ | _______ |
| `ret` (first time)          | _______ | _______ |
| `call add_sub` (second time)| _______ | _______ |
| `ret` (second time)         | _______ | _______ |

Code for reference:
```asm
_start:  li   a0, 2
         call add_sub
after1:  li   a0, 3
         call add_sub
after2:  j    go
add_sub: add  a0, a0, a0
         ret
```

---

## Part C: .text / .data / .align

**5.** Fill in the missing directive so the next label is on a 4-byte boundary.

```asm
.data
mybyte:  .byte 0x11
______   # align to 4-byte boundary
myword:  .word 0xdeadbeef
```

**6.** What does `.align 2` mean? (Boundary in bytes: 2^n = ?)

**7.** Fix the program so the word load is safe (no alignment fault). Add the minimum needed.

```asm
.global _start
.text
_start:  la   t0, value
         lw   t1, (t0)
         j    _start
.data
value:   .word 0x12345678
```

**8.** Why can `lw` "crash" if the address is not 4-byte aligned?
- _______________________

---

## Part D: Write the code

**9.** Write a tiny program that:
- Puts 7 in `a0`,
- Calls a subroutine `triple` that does `a0 = a0 * 3` (use two adds: `a0 + a0 + a0` or equivalent),
- Then loops forever with `j` to a label.

**10.** Write a `.data` section that defines:
- A byte `b1` with value 0xAB,
- Then a word `w1` with value 0x11223344, with the word 4-byte aligned.
Use the correct directive for alignment.

---

## Part E: Find the bug

**11.** Someone wrote this and said "when my_sub returns, it goes to the wrong place." Why?

```asm
helper:  add  a0, a0, 1
         call my_sub    # my_sub uses ret
         ret
```

**12.** This is supposed to load the word at `data_word` into `t2`. What's wrong?

```asm
.data
data_byte: .byte 0x55
data_word: .word 0x99aabbcc
```
(Code: `la t0, data_word` then `lw t2, (t0)`.)
- _______________________

---

## Part F: Short answer

**13.** In one sentence: why do we save `ra` on the stack before a subroutine calls another subroutine?

**14.** What two things make a piece of code a "subroutine" (how we enter and how we leave)?
- Enter: _______________________
- Leave: _______________________

---

*When you're done, check **L7_Practice_Questions_With_Answers.md** in this folder for detailed answers to similar questions and more lecture-based practice.*
