# 2025 Midterm — Q1(e) [3 marks]

## Question

Why is the **subroutine calling convention** (such as the Nios V calling convention given on page 18) **necessary**? Do not simply restate the convention, but explain **what problem it is solving**.

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

**The problem:**

- Different subroutines (and different programmers or the compiler) use **registers** for different things. For example, the **caller** might use **t0** for something important, and the **callee** might also use **t0** for something else. If the callee overwrites **t0** without the caller knowing, the **caller’s** value is lost and the program can behave incorrectly.
- Similarly, the **caller** must pass **parameters** to the callee and receive **return values** in a **fixed, agreed** way. If there is no agreement (e.g. “first parameter in a0”, “return value in a0”), the callee and caller would not communicate correctly.

**What the calling convention solves:**

- A **calling convention** is a **set of rules** that everyone (all code and compilers) follows. It specifies:
  - **Which registers** are used for parameters (e.g. a0–a7) and return values (e.g. a0, a1).
  - **Which registers** the caller may assume are preserved across a call (e.g. s0–s11) and which may be overwritten (e.g. t0–t6 — caller-saved).
  - **Who** is responsible for **saving** which registers (caller vs callee) and **where** (e.g. on the stack).
- With this **agreement**, assembly (or compiled) code from different sources can **call** each other correctly: parameters and return values are in the right places, and important register state is not lost because the rules say who must save and restore what.

**Summary:** The convention is necessary so that **different pieces of code** (written by different people or the compiler) can **call each other** without corrupting each other’s registers and with a **clear, fixed** way to pass arguments and get return values. Without that agreement, software would not interoperate correctly — information would not be passed correctly and registers would be overwritten unpredictably.
