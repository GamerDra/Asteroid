`timescale 1ns / 1ps

module player_movement (
    input wire clk,
    input wire reset,
    input wire left,
    input wire right,
    output reg [9:0] player_x
);

    // Define screen boundaries and movement speed
    parameter SCREEN_WIDTH = 640;
    parameter PLAYER_SPEED = 5;
    parameter PLAYER_MIN_X = 0;
    parameter PLAYER_MAX_X = SCREEN_WIDTH - 10; // Assuming player width of 10 pixels

    // Slow clock counter to control movement speed
    reg [20:0] counter;
    wire slow_clk = counter[20]; // Use a slower clock signal

    always @(posedge clk) begin
        counter <= counter + 1;
    end

    always @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            player_x <= SCREEN_WIDTH / 2; // Start at the middle
        end else begin
            if (left && player_x >= PLAYER_MIN_X + PLAYER_SPEED) begin
                player_x <= player_x - PLAYER_SPEED;
            end else if (right && player_x <= PLAYER_MAX_X - PLAYER_SPEED) begin
                player_x <= player_x + PLAYER_SPEED;
            end
        end
    end

endmodule
