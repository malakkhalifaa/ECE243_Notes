# ==============================================================================
# ECE 243 Lab 4 — Part IV: Real-time binary clock on 10 LEDs
# ==============================================================================
# Written by Hamda Armeen
#
# WHAT IT DOES:
#   Real-time binary clock: seconds (0..7) on LEDR9:7 (high 3 bits),
#   hundredths of a second (0..99) on LEDR6:0 (low 7 bits). One hardware
#   timer measures 0.01 s; we poll TO and advance hundredths every 0.01 s,
#   then roll seconds when hundredths hit 100. When clock reaches 7.99 s,
#   it wraps to 0.00 s. Any KEY press toggles run/stop (Edge-capture).
#
# ADDRESSES:
#   KEYS base = 0xFF200050; Edge-capture register is at base+0xC = 0xFF20005C.
#   LEDs = 0xFF200000. TIMER base = 0xFF202000 (Status 0, Control 4, Period 8/0xC).
#
# DISPLAY:
#   One 10-bit value: (seconds << 7) | hundredths.
#   Shift left by 7 puts seconds in bits 9:7 (same as seconds × 128);
#   hundredths stay in bits 6:0. So LEDR9:7 = seconds, LEDR6:0 = hundredths.
# ==============================================================================

.global _start
_start:

.equ KEYS, 0xFF200050       # KEY parallel port base; Edge-capture at base+0xC
.equ LEDs, 0xFF200000       # 10 red LEDs
.equ TIMER, 0xFF202000      # Timer: Status 0, Control 4, Period low 8, high 0xC
.equ TICK_SECONDS, 1000000 # 0.01 s at 100 MHz (ticks per hundredth of a second)

# ------------------------------------------------------------------------------
# Register setup: load addresses and initialize seconds, hundredths, run/stop
# ------------------------------------------------------------------------------
#register setup
la s0, KEYS                 # s0 = KEY base (we use 0xC(s0) for Edge-capture)
la s1, LEDs                  # s1 = LED register (we store display value here)
la s4, TIMER                 # s4 = timer base (used by wait subroutine)

li s2, 0                    # s2 = seconds (0..7)
li s3, 0                    # s3 = hundredths (0..99)
li t6, 0                    # t6 = run/stop flag: 0 = stopped, 1 = running

# ------------------------------------------------------------------------------
# Timer initialization: 0.01 s period, then START+CONT so it runs continuously
# ------------------------------------------------------------------------------
#timer initialization
sw zero, 0(s4)              # clear TO (timeout) bit in Status register

li t0, TICK_SECONDS
sw t0, 0x8(s4)              # period low 16 bits → timer offset 8
srli t1, t0, 16             # get upper 16 bits of period
sw t1, 0xC(s4)              # period high 16 bits → timer offset 0xC

# NOTE: Timer period is 32 bits; we write it in two 16-bit halves.
# The hardware combines them into one counter value automatically.

li t0, 0b0110               # bit 2 = START (1), bit 3 = CONT (1) → run continuously
sw t0, 4(s4)                 # write to Control register (offset 4)

# ------------------------------------------------------------------------------
# Main loop: poll KEY (Edge-capture) → update display → if stopped, loop;
#   else wait 0.01 s → increment hundredths (wrap 100→0, seconds++) →
#   wrap seconds 8→0 so 7.99 → 0.00.
# ------------------------------------------------------------------------------
#main loop
loop:

# --- Check for key press using Edge-capture (at KEY base + 0xC) ---
#check for key press using edge capture register
lw t0, 0xc(s0)              # load Edge-capture register (0xFF20005C); bit i=1 if KEYi was pressed+released

beqz t0, no_detection       # if t0 is 0, no key was pressed → skip to no_detection

# --- A key was pressed: toggle run/stop (t6) ---
beqz t6, continue           # if t6=0 (stopped), go to continue and set t6=1 (running)

li t6, 0                    # else was running → set t6=0 (stopped)
j done

continue:
li t6, 1                    # was stopped → set t6=1 (running)

done:
sw t0, 0xc(s0)              # clear Edge-capture: write back the value we read (writing 1 to a bit clears it)

# --- Update display: (seconds << 7) | hundredths → LEDR9:7 = seconds, LEDR6:0 = hundredths ---
no_detection:
#combine seconds and hundredths into one LED value
slli t0, s2, 7              # t0 = seconds << 7 (seconds in bits 9:7; same as seconds × 128)
add  t0, t0, s3             # t0 = (seconds << 7) + hundredths; hundredths in bits 6:0
sw t0, (s1)                 # store to LEDs: LEDR9:7 = seconds, LEDR6:0 = hundredths

beqz t6, loop               # if stopped (t6=0), keep polling KEY and updating display; do not advance time

call wait                   # wait exactly 0.01 s (poll timer TO, then clear TO)

# --- Advance time: increment hundredths; wrap hundredths at 100, seconds at 8 ---
addi s3, s3, 1              # hundredths++
li t0, 100
blt s3, t0, loop            # if hundredths < 100, go back to loop
li s3, 0                   # else hundredths = 0 (we rolled to next second)

addi s2, s2, 1              # seconds++
li t0, 9                   # we want to wrap when seconds reaches 8 (so 7.99 → 0.00)
blt s2, t0, loop            # if seconds < 9 (i.e. 0..8), continue; when s2=8 we fall through and wrap
li s2, 0                   # seconds = 0 (wrap 7.99 / 8.00 → 0.00)

j loop

# ------------------------------------------------------------------------------
# Subroutine wait: poll timer Status until TO (timeout) = 1, then clear TO.
#   Uses s4 (timer base) set by caller; does not call anything, so no stack.
# ------------------------------------------------------------------------------
#subroutine to wait for one timer tick (0.01s)
wait:

polling:
lw t0, 0(s4)                # load timer Status register (offset 0)
andi t0, t0, 0x1            # keep only bit 0 (TO: 1 = timer reached zero)
beqz t0, polling            # if TO=0, keep polling until timer fires

sw zero, 0(s4)              # TO=1: clear it by writing 0 to Status (so next period can set it again)
ret                         # return to caller (main loop)

# NOTE: s registers hold persistent values (seconds, hundredths); t registers
# are for temporary use. t6 is run/stop and can change; it is not preserved
# across calls (caller-saved), which is fine since only main loop uses it.
