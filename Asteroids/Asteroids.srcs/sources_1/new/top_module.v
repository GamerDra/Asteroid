
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2025 00:28:22
// Design Name: 
// Module Name: top_module
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


`timescale 1ns / 1ps

module top_module (
    input wire clk,        // System clock
    input wire reset,      // Reset signal
    input wire btn_left,   // Button for moving left
    input wire btn_right,  // Button for moving right
    output wire led_left,  // LED for left movement
    output wire led_right  // LED for right movement
);

    wire [9:0] player_x;  // Internal signal, not an output port

    // Instantiate the player movement module
    player_movement player_inst (
        .clk(clk),
        .reset(reset),
        .left(btn_left),
        .right(btn_right),
        .player_x(player_x)  
    );

    // Light up LEDs when moving
    assign led_left = btn_left;
    assign led_right = btn_right;

endmodule


