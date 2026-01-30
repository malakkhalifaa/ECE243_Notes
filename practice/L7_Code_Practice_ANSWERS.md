# Lecture 7 — Code Practice ANSWERS

---

## Part A: Fill in the blanks (call / ret)

**1.**
```asm
    li   a0, 5           # parameter 5
    call double_it       # call subroutine
    ...
double_it:
    add  a0, a0, a0
    ret                  # return to caller
```

**2.**  
- Step 1: `ra <- pc` (save address of next instruction).  
- Step 2: `pc <- double_it` (jump to subroutine).

**3.**  
- `ret` does: `pc <- ra` (jump back to instruction after the `call`).

---

## Part B: Trace execution

**4.**

| Instruction        | pc (after) | ra (after) |
|--------------------|------------|------------|
| `call add_sub` (1st) | 0x2000   | 0x1008     |
| `ret` (1st)         | 0x1008   | (unchanged)|
| `call add_sub` (2nd)| 0x2000   | 0x1010     |
| `ret` (2nd)         | 0x1010   | (unchanged)|

---

## Part C: .text / .data / .align

**5.**  
`.align 2`

**6.**  
`.align 2` means align to a **2² = 4 byte** boundary (not 2 bytes).

**7.**  
Add `.align 2` *before* `value` so the word is 4-byte aligned:
```asm
.data
.align 2
value:   .word 0x12345678
```
(If there were something before `value`, you’d put `.align 2` right before `value`.)

**8.**  
The processor may require word loads to be 4-byte aligned; an unaligned address can cause a fault/crash.

---

## Part D: Write the code

**9.**
```asm
.global _start
.text
_start:
    li   a0, 7
    call triple
loop:
    j    loop

triple:
    add  a0, a0, a0    # a0 = 2*a0
    add  a0, a0, a0   # a0 = 3*a0 (if we had original in a0: 7+7+7)
    # Actually for 7*3:  li t0, 7 then add 3 times, or:
    # add a1, a0, zero; add a0, a0, a0; add a0, a0, a1
    ret
```
Simpler “triple” (assuming a0 = 7):  
`add t0, a0, a0` then `add t0, t0, a0` then `add a0, t0, zero` — or two adds if we allow overwriting:  
`add a0, a0, a0` then `add a0, a0, a0` gives 4*a0; for 3*a0 you need one more copy.  
Minimal version (3*a0 using only a0 and one temp):
```asm
triple:
    add  t0, a0, a0     # t0 = 2*a0
    add  a0, t0, a0     # a0 = 3*a0
    ret
```

**10.**
```asm
.data
b1:   .byte 0xAB
.align 2
w1:   .word 0x11223344
```

---

## Part E: Find the bug

**11.**  
`helper` calls `my_sub`. The `call my_sub` overwrites `ra` with the return address *back to helper*. When `my_sub` does `ret`, we correctly return to `helper`. But when `helper` later does `ret`, it uses *that same* `ra` (pointing to after `call my_sub`), not the address of whoever called `helper`. So we never return to the original caller.  
**Fix:** Save `ra` before `call my_sub` and restore it before `helper`’s `ret` (e.g. on the stack).

**12.**  
`data_word` may not be 4-byte aligned because it comes right after a byte. So `lw` might fault.  
**Fix:** Put `.align 2` before `data_word`:
```asm
data_byte: .byte 0x55
.align 2
data_word: .word 0x99aabbcc
```

---

## Part F: Short answer

**13.**  
Because the inner `call` overwrites `ra`, so we’d lose the address to return to *our* caller. Saving/restoring `ra` (e.g. on the stack) keeps the correct return address.

**14.**  
- Enter: with **`call`** (not plain `j`).  
- Leave: with **`ret`**.
