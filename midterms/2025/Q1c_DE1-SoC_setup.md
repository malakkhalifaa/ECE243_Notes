# 2025 Midterm — Q1(c) [2 marks]

## Question

When you arrive in the lab (in the Bahen building) for this course and begin to test your work, explain what needs to happen to make the **DE1-SoC board** into the **DE1-SoC Computer System** that you used in the lab. The DE1-SoC Computer System contains a Nios V processor and Input/Output devices.

---

## Your answer:

_(Type your answer here.)_

---

## Detailed explanation / solution

The **DE1-SoC board** by itself is hardware (FPGA, switches, LEDs, etc.) but does not yet implement the **Nios V processor** or the I/O devices as a usable computer system.

**What needs to happen:**

- The **FPGA** on the DE1-SoC board must be **programmed** (configured) with the **digital hardware design** that implements:
  - The **Nios V processor** (CPU),
  - The **surrounding logic** that implements the **input/output devices** (e.g. LEDs, switches, KEY buttons, timer) as memory-mapped I/O.
- This is done by **downloading** (programming) that design into the FPGA. In the course this is typically done by:
  - Using the **monitor program** to download the system to the board, or
  - Using the **command-line process** and **makefile commands** released part-way through the term.

Once the FPGA is programmed, the board becomes the **DE1-SoC Computer System** — a system with a Nios V processor and I/O devices that your software can run on and interact with.

**Summary:** The FPGA must be **programmed** with the system design (Nios V + I/O logic). That is done by downloading the design using the monitor program or the provided makefile/command-line process.
