# ECE243 Lab 4 — Part 2: KEY press+release using Edge Capture register
# Poll Edge Capture (offset 0x0C). When KEY0 bit (bit 0) is set, toggle LED0,
# then clear the edge-capture bit by writing 1 to it. Repeat forever.
# Addresses: LEDs 0xFF200000, KEY base 0xFF200050, Edge Capture at offset 0x0C.

.global _start
.equ KEY_BASE, 0xFF200050
.equ LEDs,     0xFF200000

.text
_start:
    la   t0, KEY_BASE       # t0 = KEY parallel port base
    la   t1, LEDs           # t1 = LED parallel port base
    li   t2, 1              # t2 = current LED0 state (1 = on); will toggle

poll_loop:
    lw   t3, 0xC(t0)        # load Edge Capture Register (offset 0x0C)
    andi t3, t3, 0x1        # keep only KEY0 (bit 0)
    beqz t3, poll_loop      # if 0, no press+release yet -> keep polling

    # --- KEY0 press+release detected: toggle LED0 ---
    sw   t2, (t1)           # write current LED state to LEDs
    xori t2, t2, 1          # flip bit 0 for next time (on <-> off)

    # --- Clear Edge Capture bit 0: write 1 to that bit ---
    li   t4, 0x1            # value with bit 0 = 1 (clears bit 0 in Edge Capture)
    sw   t4, 0xC(t0)        # store to Edge Capture Register

    j    poll_loop          # repeat
