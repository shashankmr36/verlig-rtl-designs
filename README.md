UART Transmitter and Receiver in Verilog

Overview

This project implements a UART transmitter, UART receiver, and loopback connection using Verilog HDL. It verifies serial data transmission and reception through simulation.

Features

UART transmitter (TX)

UART receiver (RX)

8-bit serial data transmission, LSB first

Start and stop bit handling

Two-flip-flop synchronizer for the receiver input

TX-to-RX loopback connection

Individual and combined testbenches

Simulation waveform inspection using GTKWave

Tools Used

Verilog HDL

Icarus Verilog

GTKWave

Visual Studio Code

Project Structure

uart-verilog-project/
├── rtl/
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_loopback.v
├── tb/
│   ├── uart_tx_tb.v
│   ├── uart_rx_tb.v
│   └── uart_loopback_tb.v
├── waveform.vcd
├── uart_loopback.vcd
├── README.md
└── .gitignore

Loopback Verification

The transmitter output is connected directly to the receiver input. The testbench sends the byte 8'hA5 and checks whether the receiver reconstructs the same byte.

Test result: PASS — expected A5, received A5.

How to Run

Compile the combined design and testbench from the project root:

iverilog -o uart_loopback_tb.vvp rtl/uart_tx.v rtl/uart_rx.v rtl/uart_loopback.v tb/uart_loopback_tb.v

Run the simulation:

vvp uart_loopback_tb.vvp

Open the generated waveform:

gtkwave uart_loopback.vcd

Waveform Signals

The combined waveform can be used to inspect:

clk and reset

start and data

tx and tx_busy

rx_busy

data_out and data_valid

Learning Outcomes

Writing modular Verilog designs

Creating and running testbenches

Verifying serial communication using simulation

Debugging RTL with waveform analysis