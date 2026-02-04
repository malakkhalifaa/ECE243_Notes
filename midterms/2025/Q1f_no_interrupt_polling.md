# 2025 Midterm — Q1(f) [3 marks]

## Question

If there was **no interrupt mechanism** in a processor, but the computer system that contained the processor had **ten separate I/O devices** that were necessary to interact with, what would the **software** in the system need to do to have the **equivalent functionality** provided by interrupts?

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

**What interrupts provide:**

- With interrupts, each device can **signal** the processor when it needs attention (e.g. data ready, button pressed, timer expired). The processor then **stops** what it is doing, runs the **Interrupt Service Routine (ISR)** for that device, and **returns** to the main program. The processor does not have to constantly check each device.

**Without interrupts — what software must do:**

- The software must **poll** the devices. That means:
  - Run a **loop** that is executed **reasonably often** (e.g. repeatedly).
  - In that loop, **check each** of the ten I/O devices in turn — e.g. read each device’s status register (or data register) to see if it needs service (e.g. “data ready”, “button pressed”, “timer expired”).
  - When a device’s status indicates it **needs service**, the program must **respond** by doing the equivalent of what an ISR would do for that device (e.g. read data, flip an LED, update a counter).
- So instead of the **device** telling the processor “I need attention” (interrupt), the **processor** keeps asking “do you need attention?” for each device (polling). The result is similar functionality (devices get serviced), but the processor is always busy checking, and it is **inefficient** and hard to scale when there are many devices.

**Summary:** Without interrupts, the software would need a **polling loop** that runs often and **individually checks each** of the ten devices (e.g. reads their status); when a device indicates it needs service, the program would perform the equivalent of that device’s ISR. So: **polling** replaces **interrupts** to achieve equivalent “react to I/O” behaviour.
