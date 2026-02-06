# ==============================================================================
# ECE 243 Lab 4 — Part III: Binary counter 0–255 with HARDWARE TIMER (exact 0.25 s)
# ==============================================================================
# WHAT IT DOES:
#   Same as Part II: counter 0, 1, 2, … 255 on the 10 red LEDs, then wraps to 0.
#   One KEY press toggles run/pause. The step interval is exactly 0.25 seconds
#   (using the hardware timer), not a software delay loop.
#
# HOW WE DO IT:
#   We use the KEY Edge-capture register for stop/start (same as Part II). For
#   the delay we use the hardware timer: set its period to 0.25 s worth of
#   ticks, set CONT=1 and START=1 so it runs continuously, then poll the
#   Status register until the TO (timeout) bit is 1, clear TO, and return.
#   So each “tick” of the counter is exactly one timer period (0.25 s).
#
# WHAT TO EXPECT ON DEMO:
#   Same behaviour as Part II: KEY toggles run/pause; when running, LEDs
#   count 0→255→0 every 0.25 s per step. Timing is exact (no drift like
#   a delay loop).
#
# ADDRESSES:
#   KEYS = 0xFF20005C (Edge-capture). LEDs = 0xFF200000.
#   TIMER base = 0xFF202000: Status 0, Control 4, Period low 8, Period high 0xC.
#
# TIMER:
#   Clock 50 MHz (CPUlator) → 0.25 s = 12,500,000 ticks. Period is written in
#   two 16-bit halves (low at 0x8, high at 0xC). Control 0b0110 = START + CONT.
#   We poll Status (offset 0) for TO bit; store 0 to Status to clear TO.
# ==============================================================================

.global _start
.equ KEYS, 0xFF20005c       # KEY Edge-capture register
.equ LEDs, 0xFF200000       # LEDs
.equ TIMER, 0xFF202000      # Timer base (Status 0, Control 4, Period low 8, high 0xC)
.equ COUNTER_DELAY, 12500000   # CPUlator: 0.25 s at 50 MHz (use ~10,000,000 on board)

# Calculation: 0.25 s × 50,000,000 Hz = 12,500,000 ticks
# Written by Hamda Armeen

.text
_start:
    la   t0, KEYS            # t0 = address of KEY Edge-capture
    la   t2, LEDs            # t2 = address of LEDs
    la   t3, TIMER           # t3 = address of timer (Status at 0, Control at 4, etc.)

# ------------------------------------------------------------------------------
# One-time timer setup: clear TO, set period (low then high), then START+CONT
# ------------------------------------------------------------------------------
    sw   zero, 0(t3)         # clear TO (timeout) in case it was set
    li   t4, COUNTER_DELAY   # period = number of ticks for 0.25 s
    sw   t4, 8(t3)          # store lower 16 bits into period low register
    srli t5, t4, 16         # get upper 16 bits
    sw   t5, 0xc(t3)        # store into period high register
    # Timer hardware treats the two halves as one 32-bit period; no manual recombine

    li   s0, 0b0110         # CONT=1 (bit 3), START=1 (bit 2) → run continuously
    sw   s0, 4(t3)          # write to Control register (offset 4)

    li   s3, 255            # s3 = max counter value (wrap at 256)
    li   t6, 0              # t6 = run/stop: 0 = paused, 1 = running
    li   s2, 0              # s2 = counter value (0..255)

# ------------------------------------------------------------------------------
# POLL: read KEY Edge-capture. If no key (t1=0) → check_status. If key pressed
#   (t1 != 0) → toggle t6 (run↔pause), clear edge bits, then check_status.
# ------------------------------------------------------------------------------
poll:
    lw   t1, (t0)            # t1 = Edge-capture (any key pressed+released?)
    beqz t1, check_status    # no key → go see if we're running or paused

    # A key was pressed: toggle run/stop
    beqz t6, change_status_one
    li   t6, 0               # was running → now paused
    j    status_change_done
change_status_one:
    li   t6, 1               # was paused → now running
status_change_done:
    sw   t1, 0(t0)           # clear Edge-capture (store back the value we read)

check_status:
    beqz t6, poll            # if paused (t6=0), keep polling; don't count

start_counter:
    bge  s2, s3, reset       # if s2 >= 255, wrap to 0
    addi s2, s2, 1
    sw   s2, 0(t2)           # show counter on LEDs

    call wait_timer          # wait exactly 0.25 s (hardware timer)
    j    poll

reset:
    li   s2, 0               # wrap: set counter back to 0
    j    start_counter       # then continue counting

# ------------------------------------------------------------------------------
# Subroutine wait_timer: poll timer Status until TO (timeout) = 1, then clear TO.
#   Uses t3 = timer base (set by caller), t4 for status/TO. No stack (no nested call).
# ------------------------------------------------------------------------------
wait_timer:
wait_loop:
    lw   t4, 0(t3)           # load Status register (offset 0)
    andi t4, t4, 1           # keep only bit 0 (TO)
    beqz t4, wait_loop       # if TO = 0, keep waiting
    sw   zero, 0(t3)         # TO = 1: clear it by writing 0 to Status, then return
    ret

# NOTE: t = temp (temporary), s = save (callee-saved), a = argument (parameters).
# So t registers may be overwritten by subroutines; s and ra must be saved if used.
