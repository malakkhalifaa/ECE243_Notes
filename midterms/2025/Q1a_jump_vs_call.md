# 2025 Midterm — Q1(a) [3 marks]

## Question

What is the difference between a Nios V **jump** instruction (e.g. `j label` where label is the label of another instruction) and a **call** instruction (e.g. `call label`)? In your answer be sure to give detail about what each instruction does.

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

**Jump (`j label`):**
- **Effect:** Transfers control to the instruction at **label**.
- The **program counter (pc)** is set to the **address of that instruction**.
- Execution continues from there. **No return address is saved** — the processor does not remember where it came from.

**Call (`call label`):**
- **Effect:** Does **two** things (in order):
  1. **Saves the return address:** The processor **copies the current program counter (pc)** into the **`ra` (return address) register**. At this moment, pc points to the **next** instruction (the one after `call`), so that address is stored in `ra`. That is where we want to return after the subroutine finishes.
  2. **Transfers control to label:** The processor sets **pc** to the address of the instruction at **label** (same as a jump).
- **Why:** `call` is used to **invoke a subroutine**. The subroutine will eventually execute **`ret`**, which sets **pc ← ra**, so execution returns to the instruction **after** the `call`. Without saving the return address in `ra`, we would not know where to return.

**Summary:**  
- **`j`** = only change pc to the target address.  
- **`call`** = first save “where to return” in **ra** (address of next instruction), then jump to the target. So **call** is for subroutines; **ret** uses **ra** to return.
