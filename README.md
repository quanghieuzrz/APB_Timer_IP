# APB_Timer_IP (64-bit Counter / 32-bit APB Bus)

![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Language](https://img.shields.io/badge/Language-Verilog-blue.svg)
![Bus Interface](https://img.shields.io/badge/Bus%20Interface-APB4-orange)
![Counter](https://img.shields.io/badge/Counter-64--bit-purple.svg)
![Status](https://img.shields.io/badge/Status-Synthesizable-brightgreen.svg)

This repository contains a 64-bit Timer IP Core with APB Slave interface, customized based on the RISC-V CLINT (Core Local Interruptor) specification. The IP supports configurable counting speeds, hardware maskable level-interrupts, and debug mode halting.

---

## Key Features

* **Bus Interface:** APB Slave interface with 12-bit address space.
* **Counter:** 64-bit up-counter with configurable clock division (up to divide-by-256).
* **Interrupt:** Level-sensitive, maskable hardware timer interrupt (`tim_int`).
* **Advanced Features:**
  * Byte-enable write support (`tim_pstrb[3:0]`).
  * 1-cycle wait-state insert for timing closure (`tim_pready`).
  * Error response generation (`tim_pslverr`) for illegal access or changing configuration while timer is active.
  * Debug mode support: Counter halts when `dbg_mode` and `halt_req` are active.

---

## Detailed Functional Specification

### Counter Operation
* **64-bit Up-Counter:** Counts up continuously even when interrupts or counter overflows occur.
* **Auto-Clear (Advanced Level):** When `timer_en` transitions from High to Low ($1 \rightarrow 0$), the counter value is automatically cleared to its initial value (`64'h0`). When re-enabled ($0 \rightarrow 1$), counting resumes normally.
* **Counting Speed:** Controlled via `TCR.div_en` and `TCR.div_val`. 
  > **Note:** `div_en` and `div_val` do NOT act as a standard hardware clock frequency divider. They only control the rate/enable condition at which the counter increments.

### Debug & Halted Mode (Advanced Level)
* **Halt Conditions:** The counter is suspended (halted) when **BOTH** conditions are met:
  1. Input signal `dbg_mode` is HIGH (`1`).
  2. Control register bit `THCSR.halt_req` is set to HIGH (`1`).
* **Halt Acknowledge:** `THCSR.halt_ack` is automatically driven to HIGH (`1`) once the halt request is accepted.
* **Resume Operation:** Clearing `THCSR.halt_req` to `0` resumes counting. The timing period for each count step remains unchanged across halt/resume events (as shown in the functional waveform).

### Counting Modes & Clock Division
* **Default Mode (`div_en = 0`):** Counter increments every system clock cycle (`div_val = 0`).
* **Prescaled Mode (`div_en = 1`):** Counting speed is determined by `TCR.div_val[3:0]`:
  * `div_val = 0`: Increment every 1 cycle
  * `div_val = 1`: Increment every 2 cycles
  * `div_val = 2`: Increment every 4 cycles
  * `div_val = 3`: Increment every 8 cycles (up to divide-by-256 for `4'b1000`)

---

### Hardware Protection & Error Handling (Advanced Level)
* **Configuration Lock:** Modifying `TCR.div_en` or `TCR.div_val` while `timer_en` is HIGH (`1`) is strictly prohibited.
* **Error Response:** Any illegal write attempt to change prescaler settings while the timer is actively running will:
  1. Trigger an APB slave error response (`tim_pslverr = 1`).
  2. Block the invalid data from being written into the `TCR` register bitfields.
---

## Register Map Summary

Addresses in the reserved space (`Others`) are RAZ/WI (Read-As-Zero, Write-Ignored).

| Offset | Abbreviation | Register Name | Description |
| :--- | :--- | :--- | :--- |
| `0x00` | **TCR** | Timer Control Register | Enable timer, clock divider controls |
| `0x04` | **TDR0** | Timer Data Register 0 | Counter value [31:0] (Lower) |
| `0x08` | **TDR1** | Timer Data Register 1 | Counter value [63:32] (Upper) |
| `0x0C` | **TCMP0** | Timer Compare Register 0 | Compare value [31:0] (Lower) |
| `0x10` | **TCMP1** | Timer Compare Register 1 | Compare value [63:32] (Upper) |
| `0x14` | **TIER** | Timer Interrupt Enable Register | Enable/Disable timer interrupt output |
| `0x18` | **TISR** | Timer Interrupt Status Register | Pending interrupt status (Write-1-to-Clear) |
| `0x1C` | **THCSR** | Timer Halt Control Status Register | Debug halt request & acknowledge status |
| *Others* | **Reserved** | Reserved Space | RAZ / WI |

---

## Detailed Register Specifications

### 1. TCR - Timer Control Register (`0x00`)

| Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :--- |
| 31:12 | Reserved | RO | `20'h0` | Reserved, read as zero. |
| 11:8 | `div_val` | RW | `4'b0001` | **Counter Prescaler Selector**:<br>• `4'b0000`: Speed divided by 1<br>• `4'b0001`: Speed divided by 2 (default)<br>• `4'b0010`: Speed divided by 4<br>• `4'b0011`: Speed divided by 8<br>• `4'b0100`: Speed divided by 16<br>• `4'b0101`: Speed divided by 32<br>• `4'b0110`: Speed divided by 64<br>• `4'b0111`: Speed divided by 128<br>• `4'b1000`: Speed divided by 256<br>• *Others (`4'b1001`-`4'b1111`)*: **Prohibited settings**. |
| 7:2 | Reserved | RO | `6'b0` | Reserved, read as zero. |
| 1 | `div_en` | RW | `1'b0` | **Counter Control Mode Enable**:<br>• `0`: Disabled (counts at system clock speed).<br>• `1`: Enabled (counting speed controlled by `div_val`). |
| 0 | `timer_en` | RW | `1'b0` | **Timer Enable**:<br>• `0`: Disabled (does not count).<br>• `1`: Enabled (starts counting).<br>*Advanced:* High-to-Low ($1 \rightarrow 0$) transition clears `{TDR1, TDR0}` to initial value (`64'h0`). |

---

### 2. TDR0 & TDR1 - Timer Data Registers (`0x04`, `0x08`)

| Address | Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `0x04` | 31:0 | `TDR0` | RW | `32'h0000_0000` | Lower 32-bit of 64-bit counter. |
| `0x08` | 31:0 | `TDR1` | RW | `32'h0000_0000` | Upper 32-bit of 64-bit counter. |

* **Auto-Clear (Advanced Level):** Values of `TDR0` and `TDR1` are cleared back to `32'h0000_0000` when `timer_en` changes from High-to-Low ($1 \rightarrow 0$).

---

### 3. TCMP0 & TCMP1 - Timer Compare Registers (`0x0C`, `0x10`)

| Address | Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `0x0C` | 31:0 | `TCMP0` | RW | `32'hFFFF_FFFF` | Lower 32-bit of 64-bit compare match value. |
| `0x10` | 31:0 | `TCMP1` | RW | `32'hFFFF_FFFF` | Upper 32-bit of 64-bit compare match value. |

* **Interrupt Trigger:** Timer interrupt is asserted when `{TDR1, TDR0} == {TCMP1, TCMP0}`.

---

### 4. TIER - Timer Interrupt Enable Register (`0x14`)

| Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :--- |
| 31:1 | Reserved | RO | `31'h0` | Reserved, read as zero. |
| 0 | `int_en` | RW | `1'b0` | **Timer Interrupt Enable**:<br>• `0`: Disabled (`tim_int` masked to 0).<br>• `1`: Enabled (`tim_int` output when trigger condition met).<br>*Note:* Clearing to `0` masks `tim_int` but does not clear `TISR.int_st`. |

---

### 5. TISR - Timer Interrupt Status Register (`0x18`)

| Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :--- |
| 31:1 | Reserved | RO | `31'h0` | Reserved, read as zero. |
| 0 | `int_st` | RW1C | `1'b0` | **Timer Interrupt Pending Status**:<br>• `0`: No interrupt trigger condition.<br>• `1`: Trigger condition occurred.<br>*Note:* Write `1` to clear. Writing `0` has no effect. Counter continues normal operation after assertion. |

---

### 6. THCSR - Timer Halt Control Status Register (`0x1C`)

| Bits | Name | Type | Reset Value | Description |
| :---: | :---: | :---: | :---: | :--- |
| 31:2 | Reserved | RO | `30'h0` | Reserved, read as zero. |
| 1 | `halt_ack` | RO | `1'b0` | **Timer Halt Acknowledge Status (Advanced Level)**:<br>• `0`: Timer is NOT halted.<br>• `1`: Timer is halted.<br>Set to `1` when `dbg_mode == 1` and `halt_req == 1`. |
| 0 | `halt_req` | RW | `1'b0` | **Timer Halt Request (Advanced Level)**:<br>• `0`: No halt request.<br>• `1`: Request timer to halt. |

---

## Hardware Error Protection Rules (Advanced Level)

An APB error response (`tim_pslverr = 1`) is generated, and **write data is blocked (not written into registers)** when:
1. Writing prohibited values (`4'b1001` to `4'b1111`) to `TCR.div_val`.
2. Attempting to modify `TCR.div_en` or `TCR.div_val` while `timer_en` is active (`1`).

---

## IO Port List

**Top Module Name:** `timer_top`

| Signal Name | Width | Direction | Description |
| :--- | :---: | :---: | :--- |
| `sys_clk` | 1 | Input | System Clock |
| `sys_rst_n` | 1 | Input | Active-Low Asynchronous Reset |
| `tim_psel` | 1 | Input | APB Select Signal |
| `tim_pwrite` | 1 | Input | APB Write Control Signal |
| `tim_penable` | 1 | Input | APB Enable Signal |
| `tim_paddr[11:0]` | 12 | Input | APB Address Bus |
| `tim_pwdata[31:0]` | 32 | Input | APB Write Data Bus |
| `tim_prdata[31:0]` | 32 | Output | APB Read Data Bus |
| `tim_pstrb[3:0]` | 4 | Input | APB Byte Strobe (Byte-wise write enable) |
| `tim_pready` | 1 | Output | APB Ready Signal (1-cycle wait state support) |
| `tim_pslverr` | 1 | Output | APB Error Response Signal |
| `tim_int` | 1 | Output | Active-High Level Interrupt Output |
| `dbg_mode` | 1 | Input | Debug Mode Input Signal (Does not change after `timer_en` is High) |
---

## Author

**Hieu Bui**
* 💼 **LinkedIn:** [quanghieuzrz](https://www.linkedin.com/in/quanghieuzrz/)
* ✉️ **Email:** hieubuiquang2006@gmail.com
* 📞 **Phone:** (+84) 868677412

