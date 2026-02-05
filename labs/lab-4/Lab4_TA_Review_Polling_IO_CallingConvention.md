# Lab 4 — TA Review (human answers + lots of lab questions)

Stuff the TA might ask, in plain language. Practice saying the answers out loud so you sound natural.

---

## Part 1 — LED control with KEYs (Data register only)

**What does Part 1 do?**  
You show a number 0–15 on the 10 LEDs. KEY0 sets it to 1, KEY1 bumps it up (max 15), KEY2 bumps it down (min 1), KEY3 blanks it (0). After you blank it, pressing KEY0, KEY1, or KEY2 brings it back to 1.

**Why do we start at 1?**  
The handout says the display starts at 1. So we put 1 in a register and store it to the LEDs right at the start.

**Why can’t we use the Edge-capture register in Part 1?**  
The lab wants us to use only the Data register first. That way you see the downside: we have to poll for press *and* for release, and we could miss a really quick press. Later in Part 2 we switch to Edge-capture so we don’t miss presses during the delay.

**What’s the Data register for the KEYs?**  
It’s at the KEY base address, offset 0. When you read it, bit 0 is KEY0, bit 1 is KEY1, etc. If the key is pressed, that bit is 1; when you release, it goes back to 0. So it’s literally “right now, is the button down or not.”

**Why do we wait for the key to be released after we see it pressed?**  
So one physical press = one action. If we didn’t wait, we’d loop back, see the key still pressed, and do the same action again and again until you let go. Waiting for release makes it feel like one click.

**What if we didn’t wait for release?**  
The number would jump or change super fast while you hold the key, and it’d be hard to control. So we always do “see press → do the action → wait until all keys are released → then go back to polling.”

**Why does KEY2 need special handling when the display is 0?**  
When the display is blank (0), the handout says “pressing any other KEY should return the display to 1.” So when we’re at 0 and you press KEY2, we should show 1, not try to decrement (we’re already at the minimum).

**Why don’t we let the display go above 15 or below 1?**  
The lab says: don’t go above 15 (that’s 1111 in binary, fits in 4 bits), and don’t go below 1. So we check before incrementing or decrementing and just skip the change if we’d go out of range.

**What address do we write to for the LEDs?**  
0xFF200000. We store a word; only the bottom 10 bits matter (one bit per LED).

---

## Part 2 — Counter 0–255 with delay loop + Edge-capture

**What does Part 2 do?**  
A counter that goes 0, 1, 2, … up to 255 on the LEDs, then wraps to 0. It steps roughly every 0.25 seconds. Pressing any KEY toggles run/pause.

**Why do we use Edge-capture here instead of the Data register?**  
Because we have a long delay loop. If we only looked at the Data register, we’d only check when we’re *not* in the delay. So if you press the key while we’re stuck in the delay, we’d never see it. Edge-capture “remembers” that a key was pressed (and released) until we read it and clear it, so we don’t miss it.

**What’s the Edge-capture register?**  
It’s at KEY base + 0x0C. When you press *and* release a key, the corresponding bit gets set to 1 and it *stays* 1 until we clear it. So we can check it whenever we get back from the delay and still see that someone pressed a key.

**How do we clear the Edge-capture bits?**  
You store a 1 into the bit you want to clear. Yeah, it’s backwards from what you’d guess—writing 1 clears it, writing 0 leaves it alone. So to clear all four keys we store 0xF (all four bits 1) to that register.

**What’s in the delay loop?**  
We load a big number (like 10 million on the board or 500 thousand in CPUlator) into a register and then keep subtracting 1 until we hit zero. That burns time so the counter doesn’t change too fast. It’s only *approximately* 0.25 s because it depends on how fast the CPU runs.

**Why different delay values for board vs CPUlator?**  
The real board runs at full speed; CPUlator is way slower. So we use a smaller number in the simulator so we don’t wait forever. On the board we use something like 10,000,000 to get close to 0.25 s.

**What does “stop/start” mean?**  
We have a variable (like 0 = paused, 1 = running). When we see any key in Edge-capture, we flip that variable. If we’re running we go to paused; if we’re paused we go to running. So one press = toggle.

---

## Part 3 — Same as Part 2 but with the hardware timer

**What’s different from Part 2?**  
Same idea—counter 0–255, stop/start on any KEY—but instead of a software delay loop we use the actual timer hardware. So the 0.25 s is *exact* (or as exact as the crystal).

**Why use the hardware timer?**  
The delay loop is approximate; the timer counts real clock cycles at 100 MHz. So 0.25 s = 25 million ticks, and we wait until the timer says “I’ve counted that many,” then we clear the timeout bit and go again.

**What’s the timer base address?**  
0xFF202000. Status is at offset 0 (we poll the TO bit), Control at 4, and the period goes in two halves at 0x8 (low 16 bits) and 0xC (high 16 bits).

**How do we set up the timer for 0.25 s?**  
At 100 MHz, 0.25 s is 25,000,000. We put the low 16 bits in the register at offset 0x8 and the high 16 bits (we get them by shifting right 16) in the register at 0xC. Then we write 0x6 to the Control register so it starts and runs continuously.

**How do we wait for the 0.25 s in code?**  
We loop: load the Status register (offset 0), mask off the bottom bit (that’s TO). If it’s 0 we keep looping. When the timer hits zero it sets TO to 1, so we see it, then we write 0 to Status to clear TO, and then we’re done waiting and can go back to the main loop.

**Why do we have to clear the TO bit?**  
So the next time we wait we can tell when the *next* 0.25 s has passed. If we didn’t clear it, we’d think it was already done and wouldn’t really wait.

---

## Part 4 — Binary clock

**What does Part 4 do?**  
A little clock on the 10 LEDs: the top 3 LEDs are seconds (0–7) and the bottom 7 are hundredths of a second (0–99). So you see something like “2.50” in binary. It runs until 7.99 then wraps to 0.00. Any KEY toggles run/pause.

**Why only 0–7 for seconds?**  
We only have 3 bits for seconds, so the max is 7. The lab says when we hit 7.99 we wrap to 0.00.

**How do we get 0.01 s (one hundredth)?**  
We use the timer with 1,000,000 ticks at 100 MHz—that’s exactly 0.01 s. So every time the timer times out we add one to hundredths, and when hundredths hit 100 we zero them and add one to seconds.

**Why do we need a stack in Part 4?**  
Because we use a subroutine (e.g. “wait for 0.01 s”). The subroutine uses `call` and `ret`, and it has to save `ra` and any callee-saved registers it uses (like s4 for the timer base) on the stack so we don’t mess up the caller when we return.

---

## Polling and I/O (general)

**What is polling in your own words?**  
It’s when the program keeps asking “are you ready yet?” in a loop. We load the device register, check a bit, and if it’s not what we want we branch back and try again. So we’re synchronizing with the device by constantly checking instead of the device interrupting us.

**Why do we need something like polling?**  
The CPU and the buttons/timer don’t share a brain. We need a way to know *when* something happened—like “user pressed a key” or “0.25 s has passed.” Polling is one way: we keep looking until we see it.

**What’s the downside of polling?**  
We burn a lot of time just checking. And if we’re busy (e.g. in a long delay), we might not check for a while and miss an event. That’s why in Part 2 we use Edge-capture so a key press during the delay is still recorded.

**What does “memory-mapped I/O” mean?**  
It means the hardware devices look like memory. They have addresses. When we do a load or store to 0xFF200000 we’re not touching RAM—we’re talking to the LED hardware. So we use the same `lw` and `sw` instructions; the address decides whether it goes to real memory or to a device.

**What addresses do we care about in this lab?**  
LEDs at 0xFF200000, KEYs at 0xFF200050 (Data at 0, Edge-capture at 0xC), and the interval timer at 0xFF202000.

---

## Calling convention (registers and stack)

**Who’s the caller and who’s the callee?**  
The caller is the code that does `call something`. The callee is “something”—the subroutine that gets run. So main is the caller when it does `call wait_timer`; `wait_timer` is the callee.

**What does `call` actually do?**  
Two things: it saves “where to come back to” in `ra` (the next instruction after the call), then it jumps to the subroutine. So when the subroutine does `ret`, we put `ra` back into the program counter and we’re back where we started.

**What does `ret` do?**  
It just jumps to the address in `ra`. So we go back to the instruction right after the `call`.

**What are caller-saved registers?**  
t0 through t6. The *caller* has to save them if it cares about their values after the call, because the callee is allowed to use them and trash them. So before we `call`, if we need t0 later, we push it on the stack (or save it somewhere) and pop it back after the call.

**What are callee-saved registers?**  
s0 through s11. If the *callee* wants to use one of these, it has to save it at the start of the subroutine (e.g. push on stack), use it, then restore it before `ret`. So when we return, the caller’s s0–s11 are still what they were. That’s why in our delay or timer subroutine we save s0 or s4 and restore them before returning.

**Where do we pass parameters?**  
First 8 go in a0–a7. The caller puts them there before the call; the callee reads them. If we need more, we use the stack.

**Where does the return value go?**  
Usually in a0 (and a1 if there’s a second word). The callee puts the result there before `ret`.

**Why do we save `ra` on the stack when a subroutine calls another subroutine?**  
Because the inner `call` will overwrite `ra` with *its* return address. So when the outer subroutine later does `ret`, it would use that wrong address and jump to the wrong place. So the outer one has to push `ra` before it calls anyone and pop it back before its own `ret`.

**Why is the stack LIFO?**  
Subroutines return in reverse order of how they were called. So the last thing we saved (the last call’s return address) is the first thing we need to restore. That’s exactly “last in, first out”—push when we call, pop when we return.

**How do you push one word on the stack?**  
Decrement the stack pointer by 4 (`addi sp, sp, -4`), then store the register at `0(sp)`. So we’re “pushing” down in memory.

**How do you pop?**  
Load from `0(sp)` into the register, then add 4 to sp (`addi sp, sp, 4`).

---

## Timer (quick facts)

**What’s the timer clock?**  
100 MHz on the DE1-SoC. So every tick is 10 ns.

**How many ticks for 0.25 s?**  
0.25 × 100,000,000 = 25,000,000.

**How many ticks for 0.01 s?**  
0.01 × 100,000,000 = 1,000,000. We use that in Part 4 for hundredths.

**Where do we read “did the timer hit zero”?**  
Status register, offset 0 from the timer base. Bit 0 is TO (timeout). When the counter reaches 0, the hardware sets that bit to 1.

**How do we clear TO?**  
Write 0 to the Status register (offset 0). So `sw zero, 0(timer_base)`.

**What do we write to Control to start and run continuously?**  
0x6 (binary 0110)—that’s START and CONT. So it starts and when it hits zero it reloads and runs again.

---

## One-liners (for when the TA wants a short answer)

- **Polling:** Keep loading and testing a register until we see what we want.
- **Data register (KEY):** Tells you *right now* if each key is pressed (1) or not (0).
- **Edge-capture (KEY):** Remembers “a key was pressed and released” until we clear it; so we don’t miss it during a long delay.
- **Clear edge bit:** Store 1 into that bit (weird but that’s how the hardware works).
- **Caller-saved:** t0–t6; caller saves them if it needs them after the call.
- **Callee-saved:** s0–s11; callee saves them if it uses them.
- **Parameters:** a0–a7 for the first 8.
- **Return value:** a0 (and a1 for a second word).
- **call:** Saves return address in ra, then jumps to the subroutine.
- **ret:** Jumps back to the address in ra.
- **0.25 s at 100 MHz:** 25,000,000 ticks.
- **Clear timer TO:** Write 0 to Status (offset 0).
- **Start timer continuous:** Write 0x6 to Control (offset 4).

---

Practice answering these like you’re explaining to a friend—that way you’ll sound natural when the TA asks.
