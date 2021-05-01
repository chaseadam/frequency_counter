`default_nettype none
`timescale 1ns/1ps
module seven_segment (
    input wire          clk,
    input wire          reset,
    input wire          load,
    input wire [3:0]    ten_count,
    input wire [3:0]    unit_count,
    output reg [6:0]    segments,
    output reg          digit
);

    reg [3:0] tens;
    reg [3:0] units;
    wire [3:0] decode;

    always @(posedge clk) begin
        if (reset) begin
            tens <= 0;
            units <= 0;
            digit <= 0;
        end else begin
            if (load) begin
                tens <= ten_count;
                units <= unit_count;
            end
            // flip flop between segment cathode
            digit <= ~digit;
        end
    end

    assign decode = digit ? tens : units;

    always @(*) begin
        case(decode)
            //                7654321
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111100;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1100111;
            default:
                segments = 7'b0000000;
        endcase
    end

endmodule
