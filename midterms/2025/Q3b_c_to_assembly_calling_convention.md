# 2025 Midterm — Q3(b) [6 marks]

## Question

Translate the following C code into Nios V assembly. Use the **Nios V calling convention** (e.g. parameters in **a0–a7**, return value in **a0**; caller-saved **t0–t6**, callee-saved **s0–s11**).

```c
int main(void) {
    int x, y, z;
    x = foo(2);
    y = foo(3);
    z = x + y;
}

int foo(int a) {
    return (a + a + a);
}
```

---

## Your answer:

_(Write your assembly below.)_

```asm

```

---

## Detailed explanation / solution

**Calling convention (short):**

- **First argument** → **a0**; **return value** → **a0**.
- **Caller** saves **t0–t6** if it needs them after the call; **callee** saves **s0–s11** if it uses them.
- **foo** only needs **a0** (and a temp); we can use **t0** in **foo** (caller-saved, so caller must save if it needs **x** or **y** in a register). Here we can store **x** and **y** in memory and reload for **z = x + y**.

**One possible implementation:**

```asm
_start:
    la   s0, x          # base address for x, y, z (optional; can use labels)
    li   a0, 2
    call foo
    sw   a0, x          # x = foo(2)

    li   a0, 3
    call foo
    sw   a0, y          # y = foo(3)

    lw   t0, x
    add  t0, t0, a0     # a0 still holds y (return value of last foo)
    sw   t0, z          # z = x + y

done:
    j    done

foo:
    mv   t0, a0         # t0 = a
    add  a0, a0, a0     # a0 = 2*a
    add  a0, a0, t0     # a0 = 3*a
    ret

x:  .word 0
y:  .word 0
z:  .word 0
```

**Alternative (using s0 as pointer):**

```asm
_start:
    la   s0, x
    li   a0, 2
    call foo
    sw   a0, (s0)       # x

    li   a0, 3
    call foo
    sw   a0, 4(s0)      # y

    lw   t0, (s0)
    add  t0, t0, a0
    sw   t0, 8(s0)      # z
    j    done

foo:
    mv   t0, a0
    add  a0, a0, a0
    add  a0, a0, t0
    ret

x:  .word 0
y:  .word 0
z:  .word 0
```

**Notes:**

- **foo** uses **t0**; caller doesn’t need **t0** across the call for **x** and **y** because we store them in memory.
- After **y = foo(3)**, **a0** holds **y**; so **z = x + y** is **lw t0, x** then **add t0, t0, a0** then **sw t0, z**.
