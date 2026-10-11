`timescale 1ns/1ps

module uart_tx #(
    parameter CLKS_PER_BIT=4
)(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0]data,
    output reg tx,
    output reg busy
);

reg [9:0]data_frame;
reg [3:0]bit_index;
reg [31:0]baud_counter;

always@(posedge clk)begin
    if(reset)begin
        tx<=1'b1;
        data_frame<=10'b1111111111;
        busy<=1'b0;
        bit_index<=4'd0;
        baud_counter<=32'd0;
    end

    else begin
        if(!busy)begin
            baud_counter<=32'd0;
            tx<=1'b1;

            if(start)begin
                busy<=1'b1;
                tx<=1'b0;
                bit_index <= 4'd0;
                data_frame<={1'b1,data,1'b0};
            end
        end
        else begin
            if(baud_counter==CLKS_PER_BIT-1)begin
                baud_counter<=32'd0;
                
                if(bit_index<4'd8)begin
                    tx<=data_frame[bit_index+1'b1];
                    bit_index<=bit_index+1'b1;
                    
                    
                end
                else if(bit_index==4'd8)begin
                    tx<=1'b1;
                    bit_index<=4'd9;
                end
                    
                else begin
                    tx<=1'b1;
                    busy<=1'b0;
                    bit_index<=4'd0;
                end
            end
            else begin
                baud_counter<=baud_counter+1'b1;
            end
        end
    end
end
endmodule