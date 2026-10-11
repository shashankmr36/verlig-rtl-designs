
`timescale 1ns/1ps

module uart_rx_tb;

    reg clk, reset;
    reg rx;

    wire [7:0] data_out;
    wire busy;
    wire data_valid;

    reg [7:0] expected_data;

    integer i;
    integer errors;

    localparam CLKS_PER_BIT = 4;
    localparam BIT_PERIOD = CLKS_PER_BIT * 10;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .busy(busy),
        .data_valid(data_valid)
    );

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, uart_rx_tb);

        clk = 1'b0;
        reset = 1'b1;
        rx = 1'b1;
        expected_data = 8'hC3;
        errors = 0;

        // Apply reset
        repeat (4) @(negedge clk);
        reset = 1'b0;

        // Wait for the synchronizer
        repeat (3) @(negedge clk);

        // Send start bit
        rx = 1'b0;
        #(BIT_PERIOD);

        // Send 8 data bits, LSB first
        for (i = 0; i < 8; i = i + 1) begin
            rx = expected_data[i];
            #(BIT_PERIOD);
        end

        // Send stop bit
        rx = 1'b1;
        #(BIT_PERIOD);

        // Allow the receiver to finish
        wait (data_valid == 1'b1);
        #1;

        // Check received data
        if (data_out !== expected_data) begin
            $display(
                "mismatched data: expected %h, got %h",
                expected_data, data_out
            );
            errors = errors + 1;
        end
        else begin
            $display(
                "data matched: expected %h, got %h",
                expected_data, data_out
            );
        end

        // Check data_valid
        if (data_valid !== 1'b1) begin
            $display("data_valid was not asserted");
            errors = errors + 1;
        end
        else begin
            $display("data_valid asserted correctly");
        end

        // Wait for receiver to return to idle
        wait (busy == 1'b0);

        if (errors == 0)
            $display("all tests passed");
        else
            $display("test failed: %0d errors", errors);

        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

    // Simulation timeout
    initial begin
        #2000;
        $display("ERROR: Simulation timed out!");
        $finish;
    end

endmodule