module uart_loopback #(
    parameter CLKS_PER_BIT = 4
)(
    input clk,
    input reset,
    input start,
    input [7:0] data,

    output tx,
    output [7:0] data_out,
    output tx_busy,
    output rx_busy,
    output data_valid
);

    // Connect transmitter output to receiver input
    wire rx_line;

    assign rx_line = tx;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data(data),
        .tx(tx),
        .busy(tx_busy)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx_line),
        .data_out(data_out),
        .busy(rx_busy),
        .data_valid(data_valid)
    );

endmodule