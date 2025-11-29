`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/10/13 14:32:51
// Design Name: 
// Module Name: tb_MCU
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


module tb_MCU();
    logic clk;
    logic reset;
    
    // Internal signals for observation
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    logic [2:0]  strb;
    logic        busWe;
    logic [31:0] busAddr;
    logic [31:0] busWData;
    logic [31:0] busRData;
    
    // Alias for sim signal (appears to be strb based on waveform)
    logic [2:0] sim;
    assign sim = strb;
    
    MCU DUT (
        .clk(clk),
        .reset(reset)
    );
    
    // Connect internal signals for waveform viewing
    assign instrCode = DUT.instrCode;
    assign instrMemAddr = DUT.instrMemAddr;
    assign strb = DUT.strb;
    assign busWe = DUT.busWe;
    assign busAddr = DUT.busAddr;
    assign busWData = DUT.busWData;
    assign busRData = DUT.busRData;

    always #5 clk = ~clk;

    initial begin
        #0 clk = 1; reset = 1;
        #10 reset = 0;
        #4000 $finish;
    end 
endmodule
