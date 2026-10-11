`timescale 1ns/1ps

module uart_rx#(
    parameter CLKS_PER_BIT=4
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0]data_out,
    output reg busy,
    output reg data_valid
);

localparam idle =2'b00;
localparam start =2'b01;
localparam data =2'b10;
localparam stop =2'b11;
reg [7:0]shift_register;
reg [3:0]bit_index;
reg [31:0]baud_counter;
reg [1:0]state;

reg rx_sync_1;
reg rx_sync_2;

always @(posedge clk) begin
    if (reset) begin
        rx_sync_1 <= 1'b1;
        rx_sync_2 <= 1'b1;
    end
    else begin
        rx_sync_1 <= rx;
        rx_sync_2 <= rx_sync_1;
    end
end
 always@(posedge clk)begin
    if(reset)begin
        baud_counter<=32'd0;
        bit_index<=4'd0;
        busy<=1'b0;
        data_valid<=1'b0;
        shift_register<=8'b00000000;
        state <= idle;
        data_out <= 8'd0;
    end
    else begin
        data_valid<=1'b0;
        case(state)
        idle:begin
            busy<=1'b0;
            baud_counter<=32'd0;
            bit_index<=4'd0;
            

            if(rx_sync_2==1'b0)begin
                state<=start;
                busy<=1'b1;
            end
        end
        start:begin
            if(baud_counter==(CLKS_PER_BIT/2)-1)begin
                baud_counter<=32'd0;

                if(rx_sync_2==1'b0)begin
                    state<=data;
                    busy<=1'b1;
                end
                else begin
                    state<=idle;
                    busy<=1'b0;
                end
            end
            else begin
                baud_counter<=baud_counter+1'b1;
            end
        end
        data:begin
            if(baud_counter==CLKS_PER_BIT-1)begin
                baud_counter<=32'd0;
                shift_register[bit_index]<=rx_sync_2;
                if(bit_index==4'd7)begin
                    state<=stop;
                end
                else begin
                    bit_index<=bit_index+1'b1;
                end
            end
            else begin
                baud_counter<=baud_counter+1'b1;
            end
        end
        stop:begin
            if(baud_counter==CLKS_PER_BIT-1)begin
                baud_counter<=32'd0;
                state<=idle;
                busy<=1'b0;

                if(rx_sync_2==1'b1)begin
                    data_out<=shift_register;
                    data_valid<=1'b1;
                end
            end
            else begin
                baud_counter<=baud_counter+1'b1;
            end
        end
        default:begin
            state<=idle;
            busy<=1'b0;
            baud_counter<=32'b0;
        end
        endcase
    end
 end
endmodule
                    


            

                    
            



        
                
                




        

 

