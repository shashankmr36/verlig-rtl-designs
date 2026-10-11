`timescale 1ns/1ps

module uart_loopback_tb;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] data;

    wire tx;
    wire [7:0] data_out;
    wire tx_busy;
    wire rx_busy;
    wire data_valid;

    reg [7:0] expected_data;
    integer errors;

    localparam CLKS_PER_BIT = 4;

    uart_loopback #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data(data),
        .tx(tx),
        .data_out(data_out),
        .tx_busy(tx_busy),
        .rx_busy(rx_busy),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        data = 8'h00;
        expected_data = 8'hA5;
        errors = 0;

        // Reset both modules
        repeat (4) @(negedge clk);
        reset = 1'b0;

        // Provide the byte to transmit
        @(negedge clk);
        data = expected_data;
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for successful reception
        wait (data_valid == 1'b1);
        #1;

        if (data_out !== expected_data) begin
            $display("FAIL: Expected %h, received %h",
                     expected_data, data_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS: Expected %h, received %h",
                     expected_data, data_out);
        end

        if (errors == 0)
            $display("ALL LOOPBACK TESTS PASSED");
        else
            $display("LOOPBACK TEST FAILED: %0d errors", errors);

        $finish;
    end

    // Prevent an indefinite wait if reception fails
    initial begin
        #2000;
        $display("ERROR: Simulation timed out!");
        $finish;
    end

endmodule