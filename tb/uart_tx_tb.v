`timescale 1ns/1ps

module uart_tx_tb;
 reg clk,reset,start;
 reg [7:0]data;
 wire tx;
 wire busy;
 reg [7:0]expected_data;
 integer i;
 integer errors;

 localparam CLKS_PER_BIT = 4;

 localparam BIT_PERIOD = CLKS_PER_BIT * 10;

 uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
 )dut(.clk(clk),.reset(reset),.start(start),.data(data),.tx(tx),.busy(busy));
 initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,uart_tx_tb);
    clk=1'b0;
    reset=1'b1;
    start=1'b0;
    data=8'h00;
    expected_data=8'hC3;
    errors=0;

    repeat(2)@(negedge clk);
    reset=1'b0;

    @(negedge clk);
    data=expected_data;
    start=1'b1;
    
    @(negedge clk);
    #1 start=1'b0;

    #(BIT_PERIOD/2-1);

    if(tx!==1'b0)begin
        $display("wrong start bit recieved");
        errors=errors+1;
    end
    else begin
        $display("correct start bit recieved");
    end

    for(i=0;i<8;i++)begin
        #(BIT_PERIOD);
        
        if(tx!==expected_data[i])begin
            

            $display("mismatched data recieved at %0d,expected %b,got%b",i,expected_data[i],tx);
            errors=errors+1;

        end
        else begin
            $display("data matched %0d,%b",i,tx);
        end

    end
    #(BIT_PERIOD);

    if(tx!==1'b1)begin
        $display("wrong stop bit recieved");
        errors=errors+1;
    end
    else begin
        $display("correct stop bit recieved");
    end

    wait(busy==1'b0);

    if(errors==0)begin
        $display("all test passed");
    end
    else begin
        $display("test failed %0d",errors);
    end
    $finish;
 end
 
initial begin

    #2000;
     $display("ERROR: Simulation timed out!");
     $finish;
end
always #5 clk=~clk;

endmodule




        


