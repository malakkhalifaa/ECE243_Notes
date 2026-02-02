# ECE 243 Lecture 13 — Simplest interrupt-driven program
# When Key 1 is pressed (and released), cause an interrupt; each time, toggle LED 3.
# Uses CSR instructions, KEY Interrupt Mask, Edge Capture, mcause, mret.

.global _start
.equ LEDs,     0xFF200000
.equ KEY_BASE, 0xFF200050

.text
_start:
    la   sp, 0x20000          # Initialize stack pointer
    csrw mstatus, zero        # Disable processor interrupts (bit 3 MIE off) while setting up

    # Enable interrupts from KEY device: Interrupt Mask Register (offset 8)
    la   t1, KEY_BASE
    li   t0, 0b0010            # bit 1 = Key 1 only
    sw   t0, 8(t1)             # Set interrupt mask for Key 1
    sw   t0, 12(t1)            # Clear Edge Capture bit for Key 1 in case it's already on

    # Enable KEY interrupt in processor: bit 18 of MIE (KEYs use IRQ18)
    li   t0, 0x40000           # bit 18 = 1
    csrs mie, t0               # Set bit 18 of mie

    la   t0, interrupt_handler
    csrw mtvec, t0             # Set mtvec so processor knows where to go on interrupt

    li   t0, 0b1000            # bit 3 = MIE (global interrupt enable)
    csrs mstatus, t0           # Turn on MIE — enable processor interrupts

Main_loop:
    li   t0, 1                 # Main program: just set t0, t1 (check that ISR doesn't disturb them)
    li   t1, 2
    j    Main_loop

# --- Interrupt handler (processor disables MIE automatically on entry) ---
interrupt_handler:
    addi sp, sp, -12           # Room for 3 words: t0, t1, ra
    sw   t0, 0(sp)
    sw   t1, 4(sp)
    sw   ra, 8(sp)

    li   t0, 0x7FFFFFFF        # Mask: low 31 bits of mcause (exception/IRQ code)
    csrr t1, mcause
    and  t1, t1, t0            # Zero out bit 31 (interrupt vs exception)
    li   t0, 18                 # Code for KEYs in mcause
    bne  t1, t0, end_interrupt # If not KEY interrupt, skip KEY_ISR

    call KEY_ISR

end_interrupt:
    lw   t0, 0(sp)
    lw   t1, 4(sp)
    lw   ra, 8(sp)
    addi sp, sp, 12
    mret                        # Return: PC <- mepc, re-enable MIE

# --- KEY interrupt service routine: check Key 1, clear edge capture, toggle LED 3 ---
KEY_ISR:
    la   t0, KEY_BASE
    lw   t1, 12(t0)            # Load Edge Capture Register
    andi t1, t1, 0b0010        # Check Key 1 (bit 1)
    bnez t1, ok_pushed
problem:
    j    problem               # Wrong bit set — halt
ok_pushed:
    sw   t1, 12(t0)            # Clear edge capture bit for Key 1 (write 1 to that bit)
    la   t0, LEDs
    lw   t1, (t0)              # Read LEDs
    xori t1, t1, 0b1000        # Flip bit 3 (LED 3)
    sw   t1, (t0)              # Store back
    ret
