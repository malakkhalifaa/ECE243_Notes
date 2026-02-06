# Lab 4 — TA-style questions (Part 1, 2, 3 & 4)

Very specific, lecture-style questions. Practice answering out loud (cover the answers first).

---

## Part 1 — Basic polling, Data register

**1.** In Part 1, which register do we read to see if a key is pressed? What is its address?

We read the KEY Data register at 0xFF200050 (offset 0).

**2.** Why are we not allowed to use the Edge-capture register in Part 1? What would happen if we did?

Part 1 must use Data only so we see the drawback: we must poll press and release, and we could miss a quick press.

**3.** After we detect a key press in Part 1, we jump to `release_poll`. What does that loop do, and why do we need it?

release_poll waits until all keys are released (Data reg = 0) so one press = one action.

**4.** If we didn’t wait for the key to be released in Part 1, what would the user see on the LEDs?

The number would change very fast while the key is held (many actions per press).

**5.** What does `andi t3, t1, 0x1` do? Why do we use 0x1, 0x2, 0x4, 0x8 for the four keys?

AND keeps one bit; 0x1=bit0, 0x2=bit1, 0x4=bit2, 0x8=bit3 (powers of 2).

**6.** In Part 1, when the display is blank (0) and the user presses KEY2, what should happen? Why?

Display should go to 1; spec says “any other KEY” returns display to 1 when blank.

**7.** What is polling, in one sentence? Why do we need it for the KEYs?

Polling = repeatedly load and test a register until we see the condition we want.

**8.** Part 1 uses “memory-mapped I/O.” What does that mean? When we do `lw t1, (t0)` with t0 = 0xFF200050, are we reading from normal RAM?

Memory-mapped I/O = devices have addresses; load/store to that address talks to the device, not RAM.

**9.** What is the address of the LED register? How many bits of the word we store there actually drive hardware?

LEDs at 0xFF200000; bottom 10 bits drive LEDR0–LEDR9.

**10.** We check KEY0 first (bit 0), then KEY1 (bit 1), then KEY2, then KEY3. If two keys were pressed at once, which one would we respond to?

We’d respond to KEY0 (we check KEY0 first).

**11.** What does `beqz t1, poll` do in words? What does `bnez t3, key0` do?

beqz: if t1 is 0, jump to poll. bnez: if t3 is not 0, jump to key0.

**12.** Why do we need both “poll” (wait for a key) and “release_poll” (wait for release) in Part 1?

So one physical press causes exactly one action (no repeat while key is held).

---

## Part 2 — Edge-capture, delay loop, run/stop

**13.** In Part 2, what address do we use for the KEYs? Is it the same as Part 1? What is different?

Part 2 uses 0xFF20005C = Edge-capture (base + 0xC). Part 1 uses base+0 = Data.

**14.** What is the Edge-capture register? When does a bit in it become 1? When does it go back to 0?

Edge-capture: bit i = 1 after KEYi press+release; stays 1 until we clear it (store 1).

**15.** Why do we use the Edge-capture register in Part 2 instead of the Data register?

So we don’t miss a key press during the long delay loop; Edge-capture “remembers.”

**16.** If we had used the Data register in Part 2 for stop/start, what could go wrong? When might we “miss” a key press?

We’d only check when not in the delay; a press during the delay would be missed.

**17.** How do we clear a bit in the Edge-capture register? (Do we store 0 or 1 into that bit?)

Store 1 into that bit (hardware: store 1 clears the bit, store 0 leaves it).

**18.** What does t6 represent in Part 2? What value means “running”? What value means “paused”?

t6 = run/stop: 0 = paused, 1 = running.

**19.** When t6 = 0 (paused), we do poll → check_status → then what? Do we ever execute start_counter or the delay loop?

We jump back to poll; we do not run start_counter or the delay.

**20.** When t6 = 1 (running), we do poll → check_status → then what? What happens to s2 and the LEDs?

We fall through to start_counter: increment s2, show on LEDs, delay, then poll.

**21.** In the delay loop we have `li s0, COUNTER_DELAY` then we decrement s0 until 0. Why do we use `li` and not `la` for COUNTER_DELAY?

We need the value (e.g. 500000) in s0 to decrement; la would load an address.

**22.** What is COUNTER_DELAY? Why do we use a different value on the board (e.g. 10,000,000) vs CPUlator (e.g. 500,000)?

Number of loop iterations for ~0.25 s; board is faster so we need a bigger number.

**23.** In Part 2, does “poll” check which LEDs are on, or does it check whether a KEY was pressed? What does “check_status” check?

Poll checks KEYs (Edge-capture). check_status checks t6 (run or pause).

**24.** After we detect a key press in Part 2 (t1 != 0), we do `sw t1, 0(t0)`. Why do we store t1 back into the Edge-capture register?

To clear the edge bits we set (store 1 into them so they go back to 0).

**25.** What is the difference between the KEY Data register and the KEY Edge-capture register? (When does each bit change?)

Data = current key state (1=pressed, 0=released). Edge-capture = 1 after press+release, until we clear.

---

## Lecture / concepts (both parts)

**26.** What is the “polling” method of I/O? What is the alternative we’ll see later (e.g. in Lab 5)?

Polling = keep checking until ready. Alternative = interrupt-driven I/O.

**27.** In Part 1 we use only the Data register; in Part 2 we use the Edge-capture register. Which one tells you “right now, is the key pressed”? Which one tells you “a key was pressed and released at some point”?

Data = “right now, is key pressed?” Edge-capture = “did a key get pressed and released?”

**28.** Why does the lab require Part 1 to use only the Data register (no Edge-capture)? What are we meant to learn from that?

To see why Edge-capture is useful (no need to poll release; don’t miss during long delays).

**29.** The KEY parallel port has a base address. What is the offset (in bytes) of the Data register? Of the Edge-capture register?

Data at offset 0; Edge-capture at offset 0xC (12 bytes).

**30.** We use `lw` and `sw` to talk to the KEYs and LEDs. Are we reading/writing normal memory? How does the processor know to talk to the device instead of RAM?

No; those addresses are mapped to devices. The hardware decodes the address and routes to the device.

---

## Part 3 — Hardware timer, exact 0.25 s

**31.** In Part 3, how do we create the 0.25 s delay? Is it a loop like Part 2, or something else?

We use the hardware timer: set its period to 0.25 s worth of ticks, then poll the timer Status until the TO (timeout) bit is 1.

**32.** What is the base address of the timer in Part 3? What are the offsets (in bytes) of the Status register, Control register, and the two period registers?

Timer base = 0xFF202000. Status at offset 0, Control at offset 4, Period low at offset 8, Period high at offset 0xC (12).

**33.** What does the TO (timeout) bit in the timer Status register mean? When does it become 1?

TO = 1 when the timer has counted down to zero (one period has elapsed). It stays 1 until we clear it.

**34.** How do we clear the TO bit after we see it is 1?

We store 0 into the Status register (offset 0). Writing 0 clears the TO bit.

**35.** Why do we write the period in two pieces (Period low and Period high)? How many bits is the full period?

The period is 32 bits. The hardware has two 16-bit registers (low and high); we write the lower 16 bits to offset 8 and the upper 16 bits to offset 0xC.

**36.** What do the START and CONT bits in the Control register do?

START = 1 starts the timer (begins counting down). CONT = 1 means “continuous”: when the counter reaches 0, it automatically reloads the period and keeps running (so we get a new TO every 0.25 s).

**37.** What value do we store in the Control register to make the timer run continuously (CONT and START both 1)?

0b0110 (binary): bit 2 = START = 1, bit 3 = CONT = 1.

**38.** In Part 3, what is COUNTER_DELAY (e.g. 12,500,000)? How do we get that number?

It’s the number of clock ticks in 0.25 s. Formula: 0.25 s × clock frequency (e.g. 50,000,000 Hz) = 12,500,000 ticks.

**39.** Why might we use a different COUNTER_DELAY value on the real board vs CPUlator?

The board and CPUlator can run at different clock frequencies; we use a value that gives 0.25 s for each environment.

**40.** In the wait_timer subroutine, what do we load from the timer? What do we do with it before branching?

We load the Status register (offset 0). We AND it with 1 to keep only the TO bit, then branch: if TO is 0 we keep looping, if TO is 1 we clear it and return.

**41.** Who is the “caller” of wait_timer? Who is the “callee”?

The caller is the main loop (start_counter) that does `call wait_timer`. The callee is the wait_timer subroutine.

**42.** Does wait_timer use the stack? Does it need to save ra?

In this version it does not use the stack. It does not call another subroutine, so it does not need to save ra; `ret` uses the ra that `call` set.

**43.** What is the main difference between Part 2 and Part 3 in terms of how we wait 0.25 s?

Part 2: software delay loop (decrement a register until 0). Part 3: hardware timer (poll Status until TO = 1). Part 3 gives exact timing; Part 2 is approximate and can drift.

**44.** After we clear TO in wait_timer, does the timer stop? Why or why not?

No. We set CONT = 1, so the timer automatically reloads the period and counts down again; we will see TO = 1 again after another 0.25 s.

**45.** In Part 3, do we still use the KEY Edge-capture register for stop/start? Same address as Part 2?

Yes. We use the same Edge-capture register (0xFF20005C) and the same logic: any key press toggles run/pause and we clear the edge bits by storing the value back.

---

## Part 4 — Binary clock (seconds + hundredths)

**46.** In Part 4, what do the 10 LEDs represent? Which bits are seconds and which are hundredths?

Seconds (0..7) on LEDR9:7 (high 3 bits); hundredths of a second (0..99) on LEDR6:0 (low 7 bits). So display = S.HH in binary.

**47.** How do we form the single 10-bit value we store to the LEDs?

(seconds << 7) | hundredths. So slli to put seconds in bits 9:7, then add hundredths into bits 6:0.

**48.** What time interval does the timer measure in Part 4? How many ticks is that at 100 MHz?

0.01 s (10 ms). At 100 MHz, 0.01 s = 1,000,000 ticks.

**49.** When does the clock wrap? From what value to what value?

When it reaches 7.99 s (7 seconds, 99 hundredths), the next tick makes it 8.00 s; we then wrap to 0.00 s.

**50.** How do we track both seconds and hundredths with one timer?

We use one timer for 0.01 s. Every time TO fires we increment hundredths. When hundredths reach 100 we set hundredths=0 and seconds++. When seconds reach 8 we set seconds=0. So one timer drives hundredths; we derive seconds by counting hundredths.

**51.** In Part 4, do we use the KEY Data register or Edge-capture for stop/run? Why?

Edge-capture (same as Part 2/3). So we don’t miss a key press during the 0.01 s wait; Edge-capture “remembers” a press+release.

**52.** Why does wait_001_sec save s4 and ra on the stack?

Callee-saved convention: wait_001_sec uses s4 (timer base) and calls no one but ret uses ra. The caller’s ra was set by call, so we must save ra before we overwrite it (we don’t, but we use s4). We save both so the caller’s s4 and return address are restored after the call.

**53.** Who is the caller of wait_001_sec? Who is the callee?

The caller is the main loop (main_loop). The callee is the wait_001_sec subroutine.

**54.** When the clock is paused (t6=0), do we still update the display? Do we call wait_001_sec?

We still update the display every loop (so the frozen time is visible). We do not call wait_001_sec when paused; we jump back to main_loop so time doesn’t advance.

**55.** What is the difference between Part 3’s timer period and Part 4’s timer period?

Part 3: 0.25 s (e.g. 12,500,000 ticks at 50 MHz). Part 4: 0.01 s (e.g. 1,000,000 ticks at 100 MHz). Part 4 needs finer resolution for hundredths.

**56.** After we clear the Edge-capture bits in Part 4, what do we store (0 or 1 into each bit)? Why?

We store 1 into the bits we want to clear. Hardware convention: writing 1 to an edge bit clears it; writing 0 leaves it unchanged.

**57.** Why do we need a stack in Part 4?

wait_001_sec is a callee that uses s4 and returns with ret (ra). We need a stack to save and restore ra and s4 so the caller’s state is preserved across the call.

**58.** What value do we put in sp at startup? What does stack_top point to?

We set sp = stack_top. stack_top is the first word past the stack space (full-descending: we decrement sp first, then store). So the stack grows downward from stack_top.

**59.** When hundredths go from 99 to 100, what do we do to seconds and hundredths?

Set hundredths = 0 and seconds = seconds + 1. Then if seconds >= 8 we set seconds = 0 (wrap 7.99 → 0.00).

**60.** In Part 4, what does t6 represent? Same as Part 2 and Part 3?

t6 = run/stop: 0 = paused, 1 = running. Same convention as Part 2 and Part 3.

---

## Part 3 — Code-specific / detailed

**61.** In Part 3, after we write the period into the timer (low at 0x8, high at 0xC), we write 0b0110 to the Control register (offset 4). What do bits 2 and 3 of that value mean, and why do we need both set?

Bit 2 = START (1 = start counting). Bit 3 = CONT (1 = continuous: when counter hits 0, reload and run again). We need both so the timer runs over and over every 0.25 s without us having to write START again.

**62.** In Part 3’s wait_timer subroutine, we do `lw t4, 0(t3)` then `andi t4, t4, 1`. What are we loading, and what does the AND do?

We load the timer Status register (offset 0). The AND with 1 keeps only bit 0 (the TO bit) so we can branch: if TO=0 we keep looping, if TO=1 we clear it and return.

**63.** Why does Part 3’s wait_timer not use the stack? Does it call any other subroutine? Does it overwrite s4 or ra?

It doesn’t call anything, so ra is never overwritten. It only reads t3 (timer base), never writes it, so s4 (or whatever holds the timer base) is unchanged. So no save/restore is needed; no stack.

**64.** In Part 3, what is the exact formula for the timer period constant (e.g. COUNTER_DELAY or TICK value)? Why “0.25 s × clock frequency”?

Period in ticks = (time in seconds) × (clock frequency in Hz). So 0.25 s × 50,000,000 Hz = 12,500,000 ticks. The timer counts down one tick per clock cycle; when it hits 0, one period has elapsed.

**65.** In Part 3, after we clear TO by storing 0 to the Status register, does the timer stop? Why or why not?

No. We set CONT=1, so the hardware automatically reloads the period and counts down again. TO will become 1 again after another 0.25 s.

**66.** Part 3 uses t0, t2, t3 for addresses (KEYS, LEDs, TIMER) and t6 for run/stop. Why is it OK for wait_timer to use t3 and t4 without saving them?

t registers are caller-saved. The caller (main loop) doesn’t need t3 or t4 after the call; it only needs the timer base in t3 for the duration of the call. So the callee can use t3 and t4 freely.

**67.** In Part 3, when we detect a key press (Edge-capture non-zero), we toggle run/stop and then store the value we read back to the Edge-capture register. Why store it back? What does that do?

Storing the same value back (with 1s in the bits that were set) clears those edge bits. The hardware convention: write 1 to an edge bit to clear it. So we clear the edges we “consumed” so the next key press will be detected.

**68.** What is the difference between Part 2’s delay and Part 3’s delay in terms of what the CPU is doing for 0.25 s?

Part 2: CPU runs a loop decrementing a register (e.g. s0) until 0; the CPU is busy the whole time. Part 3: CPU polls the timer Status until TO=1; the timer hardware counts in parallel, so we’re just reading a register in a loop until the hardware says “done.”

---

## Part 4 — Code-specific / detailed (binary clock)

**69.** In Part 4, we use s2 for seconds and s3 for hundredths. Why put seconds in the high bits (9:7) and hundredths in the low bits (6:0) when we display?

The spec says: seconds on LEDR9:7 (high 3 bits), hundredths on LEDR6:0 (low 7 bits). So we form one 10-bit value as (seconds << 7) | hundredths so that the LEDs match that layout.

**70.** In the main loop we do `slli t0, s2, 7` then `add t0, t0, s3` then `sw t0, (s1)`. In words, what does this compute and where does it go?

We compute (s2 × 128) + s3 = (seconds << 7) | hundredths, i.e. seconds in bits 9:7 and hundredths in bits 6:0. We store that 10-bit value to the LED register (s1) so LEDR9:7 show seconds and LEDR6:0 show hundredths.

**71.** We check for a key with `lw t0, 0xc(s0)`. Why 0xc(s0) and not 0(s0)? What is at 0(s0) vs 0xC(s0)?

s0 holds the KEY base address (0xFF200050). At offset 0 we have the Data register (current key state). At offset 0xC we have the Edge-capture register (bit set when a key was pressed and released). We use Edge-capture so we don’t miss a press during the 0.01 s wait.

**72.** After we detect a key (t0 non-zero), we do `beqz t6, continue` then either `li t6, 0` and `j done` or at continue `li t6, 1`. What are we doing and why?

We’re toggling run/stop: if t6 was 0 (stopped) we set t6=1 (running); if t6 was 1 (running) we set t6=0 (stopped). So one key press flips the state.

**73.** We clear the Edge-capture by `sw t0, 0xc(s0)` (storing the value we read). Why does that clear the bits? Could we use `li t1, 0xF` and `sw t1, 0xc(s0)` instead?

The hardware clears an edge bit when you write 1 to it. We read t0 (e.g. 0x1 for KEY0); storing t0 back writes 1 to the bits that were set, so those bits get cleared. Yes, we could instead write 0xF to clear all four KEY edge bits; both are valid.

**74.** Why do we update the display (slli/add/sw to LEDs) every time through the loop, even when the clock is stopped (t6=0)?

So when stopped, the user still sees the current time (seconds and hundredths) frozen on the LEDs. If we only updated when running, the display might not show the latest time when we pause.

**75.** When hundredths reach 100 we do `li s3, 0` and `addi s2, s2, 1`. When do we set s2 back to 0? What time does that correspond to?

We set s2=0 when seconds reach 8 (i.e. after 7.99 we tick to 8.00, then we wrap to 0.00). So the clock goes 7.99 → 8.00 → 0.00 (seconds 8 is not displayed; we wrap immediately to 0).

**76.** In the code we have `li t0, 9` and `blt s2, t0, loop`. So we branch when s2 < 9. When do we *not* branch and thus execute `li s2, 0`? Is that correct for “wrap at 7.99”?

We don’t branch when s2 >= 9. But seconds go 0..7, then we add 1 and get 8. So we only ever have s2=8 when we’ve just done addi s2, s2, 1. So we need to wrap when s2 is 8. So we should branch when s2 < 8, i.e. `li t0, 8` and `blt s2, t0, loop`. With `li t0, 9` and `blt s2, t0, loop`, we branch when s2=0..7 (good) and when s2=8 we don’t branch and do li s2, 0 (correct). So t0=9 gives “branch if s2 < 9,” so we wrap when s2=8. Correct.

**77.** The wait subroutine polls `0(s4)` for the TO bit, then clears it with `sw zero, 0(s4)` and returns. Does this subroutine need to save ra or s4 on the stack? Why or why not?

No. It doesn’t call another routine, so ra is not overwritten. It only reads s4 (timer base), never writes it, so s4 is unchanged at return. So no stack needed.

**78.** What is TICK_SECONDS (e.g. 1000000) in Part 4? Why that number for 0.01 s?

It’s the number of timer clock cycles in 0.01 s. At 100 MHz, 0.01 s × 100,000,000 = 1,000,000 ticks. So the timer counts down 1,000,000 cycles and then sets TO=1.

**79.** In Part 4, when the clock is stopped (t6=0), we do `beqz t6, loop` right after updating the display. So we never call wait and never increment s3 or s2. What does the user see?

The display keeps showing the same (seconds, hundredths) because we keep writing the same (s2<<7)|s3 to the LEDs and we never advance s2 or s3. So the clock appears frozen.

**80.** Why use a subroutine (wait) for the 0.01 s delay in Part 4 instead of putting the poll loop inline in the main loop?

Clarity and reuse: the “wait for one timer tick” logic is one clear idea; putting it in a subroutine keeps the main loop easier to read and matches the spec (“use a subroutine”).
