# APB Timer IP Core

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

Base address offset space: 12-bit (`0x000` - `0xFFF`). Reserved registers read as zero (RAZ) and write-ignored (WI).

| Offset | Abbreviation | Register Name | Description |
| :--- | :--- | :--- | :--- |
| `0x00` | **TCR** | Timer Control Register | Enable timer, set clock divider |
| `0x04` | **TDR0** | Timer Data Register 0 | Counter value [31:0] (Lower) |
| `0x08` | **TDR1** | Timer Data Register 1 | Counter value [63:32] (Upper) |
| `0x0C` | **TCMP0** | Timer Compare Register 0 | Compare value [31:0] (Lower) |
| `0x10` | **TCMP1** | Timer Compare Register 1 | Compare value [63:32] (Upper) |
| `0x14` | **TIER** | Timer Interrupt Enable Register | Enable/Disable timer interrupt output |
| `0x18` | **TISR** | Timer Interrupt Status Register | Pending interrupt status (Write-1-to-Clear) |
| `0x1C` | **THCSR** | Timer Halt Control Status Register | Debug halt request & acknowledge status |

---

## Detailed Register Specifications

### 1. TCR - Timer Control Register (`0x00`)
* **Bit [0] (`timer_en`, RW, default: `1'b0`):** Timer enable. 
  * `0`: Disabled.
  * `1`: Enabled (starts counting). Transition from High-to-Low resets counter (`TDR0`/`TDR1`) to initial value.
* **Bit [1] (`div_en`, RW, default: `1'b0`):** Enable clock divider control mode.
* **Bits [11:8] (`div_val`, RW, default: `4'b0001`):** Clock division value selector ($2^N$ division up to 256).
  * *Note:* Modifying `div_en` or `div_val` while `timer_en` is High triggers an APB error response (`tim_pslverr`).

### 2. TDR0 & TDR1 - Timer Data Registers (`0x04`, `0x08`)
* **TDR0 (`0x04`):** Read/Write lower 32 bits of 64-bit counter. Default: `32'h0000_0000`.
* **TDR1 (`0x08`):** Read/Write upper 32 bits of 64-bit counter. Default: `32'h0000_0000`.
* Both registers reset to zero when `timer_en` transitions High-to-Low.

### 3. TCMP0 & TCMP1 - Timer Compare Registers (`0x0C`, `0x10`)
* **TCMP0 (`0x0C`):** Lower 32 bits of compare match value. Default: `32'hFFFF_FFFF`.
* **TCMP1 (`0x10`):** Upper 32 bits of compare match value. Default: `32'hFFFF_FFFF`.
* When `{TDR1, TDR0} == {TCMP1, TCMP0}`, the interrupt pending bit (`TISR.int_st`) is set.

### 4. TIER - Timer Interrupt Enable Register (`0x14`)
* **Bit [0] (`int_en`, RW, default: `1'b0`):**
  * `0`: Interrupt output masked (`tim_int = 0`).
  * `1`: Interrupt output enabled when trigger condition is met.

### 5. TISR - Timer Interrupt Status Register (`0x18`)
* **Bit [0] (`int_st`, RW1C, default: `1'b0`):** Interrupt status. Writes `1` to clear. Counter continues normal operation after assertion.

### 6. THCSR - Timer Halt Control Status Register (`0x1C`)
* **Bit [0] (`halt_req`, RW, default: `1'b0`):** Request timer halt in debug mode.
* **Bit [1] (`halt_ack`, RO, default: `1'b0`):** Acknowledge status. Set to `1` when `dbg_mode` is High and `halt_req` is `1`.

---

## IO Port List

**Top Module Name:** `timer_top`

| Signal Name | Width | Direction | Description |
| :--- | :---: | :---: | :--- |
| `sys_clk` | 1 | Input | System Clock |
| `sys_rst_n` | 1 | Input | Active-Low Asynchronous Reset |
| `tim_psel` | 1 | Input | APB Select Signal |
| `tim_pwrite` | 1 | Input | APB Write Control |
| `tim_penable` | 1 | Input | APB Enable Signal |
| `tim_paddr` | 12 | Input | APB Address Bus (12-bit) |
| `tim_pwdata` | 32 | Input | APB Write Data Bus |
| `tim_prdata` | 32 | Output | APB Read Data Bus |
| `tim_pstrb` | 4 | Input | APB Byte Strobe / Write Enable |
| `tim_pready` | 1 | Output | APB Ready Signal (1-cycle delay support) |
| `tim_pslverr` | 1 | Output | APB Error Response Signal |
| `tim_int` | 1 | Output | Active-High Level Interrupt Output |
| `dbg_mode` | 1 | Input | Debug Mode Input Signal |

---

## Author

**Hieu Bui**
* 💼 **LinkedIn:** [quanghieuzrz](https://www.linkedin.com/in/quanghieuzrz/)
* ✉️ **Email:** hieubuiquang2006@gmail.com
* 📞 **Phone:** (+84) 868677412

