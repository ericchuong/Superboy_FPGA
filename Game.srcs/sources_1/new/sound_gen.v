`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2017 10:42:19 AM
// Design Name: 
// Module Name: sound_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sound_gen(
    input wire clk,
    input wire [31:0] period,
    output wire audPWM
    );
    
    reg [31:0] count = 0;
    
    always @(posedge clk)
       count <= (count >= period - 1) ? 0 : count + 1;
       
    assign audPWM = (count < (period >> 1));
endmodule
