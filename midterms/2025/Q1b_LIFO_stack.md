# 2025 Midterm — Q1(b) [2 marks]

## Question

Explain why the stack needs to have the **Last-In-First-Out (LIFO)** property, in relation to calling subroutines, transmitting parameters, and saving registers.

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

**LIFO** = **Last In, First Out** — the last item pushed onto the stack is the first item popped off (like a stack of plates).

**Why the stack must be LIFO:**

- **Subroutines are executed in LIFO order:** The **last** subroutine **called** is the **first** one to **return** from. For example: main calls A, A calls B, B calls C. Returns happen in the order: C returns to B, B returns to A, A returns to main.
- **Data associated with each call must match that order:** When we **call** a subroutine, we often **push** onto the stack: the return address (if we save `ra`), parameters (if more than 8), or saved registers (caller-saved or callee-saved). When we **return**, we must **pop** that data back in the **reverse** order of the calls — i.e. the **most recently** pushed item (for the most recent call) must be the **first** we pop (when that call returns).
- So the **order in which we need to restore** data (most recent call first) is exactly the order that **LIFO** gives us: **pop** removes the **top** (last pushed) first. If the stack were FIFO (first in, first out), we would pop the **wrong** return address or saved values and the program would break.

**Summary:** Subroutines are entered and exited in LIFO order (last called, first returned). The stack holds saved state (return addresses, parameters, registers) for each call; we must restore in the **reverse** order of the calls, which is exactly what LIFO (push/pop) provides.
