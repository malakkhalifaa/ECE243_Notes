# ==============================================================================
# ECE 243 Lab 4 — Part II: Binary counter 0–255 with delay loop + Edge-capture
# ==============================================================================
# WHAT IT DOES:
#   A counter 0, 1, 2, … 255 on the 10 red LEDs, then wraps to 0. It steps
#   approximately every 0.25 seconds. Pressing ANY KEY toggles run/pause
#   (one press = pause if running, one press = run if paused).
#
# HOW WE DO IT:
#   We use the KEY EDGE-CAPTURE register (not Data) so we don't miss a key
#   press during the long delay loop. We poll Edge-capture; if any bit is 1,
#   a key was pressed (and released), so we toggle run/stop and clear the
#   edge bits by storing 1 into them. Then we either keep polling (if
#   paused) or increment the counter, show it on the LEDs, and run a delay
#   loop (decrement a big number to 0) before looping again.
#
# WHAT TO EXPECT ON DEMO:
#   Start: counter may start at 0 (or running); one KEY press = toggle
#   run/pause. When running, LEDs count up 0→1→2→…→255→0 every ~0.25 s.
#   When paused, LEDs stay the same. Press KEY again to run again.
#
# ADDRESSES:
#   KEYS = 0xFF20005C = Edge-capture register (KEY base 0xFF200050 + offset 0xC)
#   LEDs = 0xFF200000
# DELAY: COUNTER_DELAY = 500000 for CPUlator; 10000000 on board (~0.25 s)
#
# ------------------------------------------------------------------------------
# FLOW EXPLANATION (what exactly happens):
# ------------------------------------------------------------------------------
# t6 = run/stop flag:  t6 = 0 means PAUSED,  t6 = 1 means RUNNING.
#   We start with t6 = 0 (paused). One KEY press+release toggles t6 (0→1 or 1→0).
#
# POLL: We read the KEY Edge-capture register (t1 = did any key get pressed+released?).
#   We do NOT check "which LEDs are on". We check "did the user press a KEY?".
#   - If t1 = 0: no key was pressed → go to check_status.
#   - If t1 != 0: a key was pressed (and released) → toggle t6 (run↔pause), clear
#     the edge bits, then fall through to check_status.
#
# CHECK_STATUS: We look at t6 (are we running or paused?).
#   - If t6 = 0 (PAUSED): we jump back to poll. So we just keep looping: poll →
#     check_status → poll → check_status … We never increment the counter or
#     change the LEDs. The LEDs stay showing whatever s2 was last.
#   - If t6 = 1 (RUNNING): we do NOT jump; we fall through to start_counter.
#
# START_COUNTER: We increment s2 (the counter), show s2 on the LEDs (sw s2, 0(t2)),
#   then run the delay loop (burn ~0.25 s), then jump back to poll.
#   So when running: poll → check_status → start_counter (inc, display, delay) → poll …
#
# So: poll checks KEYs (Edge-capture). check_status checks t6 (run or pause).
#   If paused, we keep going poll → check_status → poll (LEDs don't change).
#   If running, we do poll → check_status → start_counter → (inc, show on LEDs, delay) → poll.
# ==============================================================================

.global _start
.equ KEYS, 0xFF20005C    # Edge-capture register address (KEY base + 0xC)
.equ LEDs, 0xFF200000
.equ COUNTER_DELAY, 500000   # CPUlator; use 10000000 on board

.text
_start:
    la   t0, KEYS        # t0 = address of Edge-capture (we read and write here)
    la   t2, LEDs        # t2 = address of LEDs

    li   s3, 255         # s3 = max counter value (we wrap at 256)
    li   t6, 0           # t6 = run/stop: 0 = paused, 1 = running (start paused)
    li   s2, 0           # s2 = counter value (0..255)
    sw   s2, 0(t2)       # show 0 on LEDs at start

# ------------------------------------------------------------------------------
# POLL: read Edge-capture. If no key was pressed (t1=0), go to check_status
#   (keep running or stay paused). If any key was pressed (t1 != 0), toggle
#   run/stop, then clear the edge bits by storing the value we read back.
# ------------------------------------------------------------------------------
poll:
    lw   t1, (t0)        # t1 = Edge-capture (bit i = 1 if KEYi was pressed+released)
    beqz t1, check_status   # no key pressed → go see if we're running or paused

    # A key was pressed: toggle run/stop
    beqz t6, change_status_one   # if currently paused (t6=0), set to running
    li   t6, 0           # was running → now paused
    j    status_change_done
change_status_one:
    li   t6, 1           # was paused → now running

status_change_done:
    sw   t1, 0(t0)       # clear Edge-capture: store 1 into the bits that were set
                         # (hardware: store 1 → clear that bit; store 0 → no change)

# ------------------------------------------------------------------------------
# CHECK_STATUS: if paused (t6=0), go back to poll. If running (t6=1), fall
#   through to start_counter (increment, display, delay).
# ------------------------------------------------------------------------------
check_status:
    beqz t6, poll        # paused → just keep polling for key press

# ------------------------------------------------------------------------------
# START_COUNTER: increment s2, wrap 256→0, show on LEDs, then delay ~0.25 s.
# ------------------------------------------------------------------------------
start_counter:
    bge  s2, s3, reset   # if s2 >= 255, wrap to 0
    addi s2, s2, 1
    sw   s2, 0(t2)       # display counter on LEDs

# --- Delay loop: burn ~0.25 s by decrementing COUNTER_DELAY to 0 ---
#   We need the VALUE (e.g. 500000) in s0, so use li (load immediate), not la.
DO_DELAY:
    li   s0, COUNTER_DELAY   # s0 = number of iterations (value, not address)
SUB_LOOP:
    addi s0, s0, -1
    bnez s0, SUB_LOOP        # loop until s0 = 0

    j    poll                # go back and check Edge-capture / run or pause

# ------------------------------------------------------------------------------
# RESET: counter hit 255, so set s2 = 0 and go back to start_counter (show 0, delay).
# ------------------------------------------------------------------------------
reset:
    li   s2, 0
    j    start_counter

# ==============================================================================
# ?????? CPUlator DEMO — how to run and what to expect ??????
# ==============================================================================
# 1. Open CPUlator, choose RISC-V DE1-SoC. Paste this file, Compile (e.g. F5).
# 2. Run (F3). LEDs = counter. Push buttons = KEY0..KEY3. We use EDGE-CAPTURE
#    (not Data), so we detect a key when it's pressed AND released.
#
# 3. What to do:
#    - Start: counter may be 0 (paused). Press any KEY (check a box, then
#      UNCHECK to release) → counter should start running (0, 1, 2, …).
#    - Press any KEY again (check + release) → counter pauses.
#    - Press again → runs again. So one press+release = toggle run/pause.
#    - When running, count goes up every ~0.25 s (or faster in CPUlator with
#      500000). At 255 it wraps to 0.
#
# 4. Why Edge-capture here: we have a long delay loop. If we used the Data
#    register we'd only check when not in the delay, so we could miss a key
#    press. Edge-capture "remembers" that a key was pressed until we read
#    and clear it, so we don't miss it.
#
# 5. TA checklist: counter 0–255 on LEDs; ~0.25 s per step on board; stop/start
#    on any KEY; Edge-capture used; clear edge by storing 1; delay loop uses
#    li s0, COUNTER_DELAY (value) for the countdown.
# ==============================================================================
