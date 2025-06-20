# UVM Testbench for Utopia Interface (ATM Protocol Verification)

This repository contains a UVM-based SystemVerilog testbench framework developed to verify the Utopia interface for the ATM protocol. 
We also developed a comprehensive test plan with a combination of constrained random tests and directed tests to meet functional coverage targets.

## 1. Device Under Test (DUT): Utopia Interface

Utopia (Universal Test and Operations PHY Interface for ATM) defines the physical interface between the PowerQUICC II processor and the PHY device.

It supports two modes:
- Master mode: controller oversees transfers  
- Slave mode: external PHY controls transfers

Key signal descriptions include RXD, TXD, RXSOC, TXSOC, RXCLAV, TXCLAV, RXENB, and TXENB.

## 2. ATM Cell Format: AAL5

An AAL5 cell is composed of:
- 48-byte payload
- 5-byte header

Header Fields:
- GFC (Generic Flow Control)
- VPI (Virtual Path Identifier)
- VCI (Virtual Channel Identifier)
- PT (Payload Type)
- C (Cell Loss Priority)
- HEC (Header Error Control)

## 3. UVM Testbench Architecture

The UVM testbench includes the following components:

- Utopia RX and TX Agents  
- CPU Agent for LUT register access  
- Utopia Sequencers and Drivers  
- Scoreboard using TLM Analysis FIFOs  
- Coverage collectors based on UVM subscribers  

Transactions are modeled as UNI and NNI cells. Sequences randomize their attributes for constrained random testing.

## 4. Test Plan

### uni_seq_test
- Sequential test  
- Randomizes UNI cell attributes and CPU forwarding address  
- Repeated for one-to-one and one-to-all transmission

### uni_parallel_test
- Parallel test using fork-join  
- Ensures DUT handles concurrent RX traffic to shared TX ports  
- Repeated for multiple combinations

## 5. Results

- Simulator: Mentor Questa 2021.3  
- All test cases passed with 0 UVM_ERROR and 0 UVM_FATAL  
- 100% functional coverage achieved

## 6. Design Highlights

- Scoreboard uses arrayed TLM FIFOs for scalable checking  
- Monitor and coverage connections made through analysis FIFOs  
- Virtual interfaces and configuration handled via `uvm_config_db`

  ### 7. Files and Directory Structure

```bash
.
├── src/ # UVM components: agents, drivers, monitors, etc.
├── results/ # Simulation logs and coverage reports
├── top.sv # Top-level module
├── README.md # Project description
└── Utopia_simulation_log_with_all_packet_transmission_messages.txt

  ```
