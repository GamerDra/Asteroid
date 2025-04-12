module color_decode(
    input [4:0] cl_frm_log,
    output reg [11:0] cl_to_vga
);

always @(*) begin
    case(cl_frm_log)
        5'b00000: cl_to_vga = 12'h000; // black
        5'b00001: cl_to_vga = 12'hF00; // red
        5'b00010: cl_to_vga = 12'h0F0; // green
        5'b00011: cl_to_vga = 12'h00F; // blue
        5'b00100: cl_to_vga = 12'h007; // navy
        5'b00101: cl_to_vga = 12'h0F0; // darkgreen
        5'b00110: cl_to_vga = 12'h0FF; // darkcyan
        5'b00111: cl_to_vga = 12'hE00; // maroon
        5'b01000: cl_to_vga = 12'hE07; // purple
        5'b01001: cl_to_vga = 12'hDF0; // olive
        5'b01010: cl_to_vga = 12'hCCD; // lightgrey
        5'b01011: cl_to_vga = 12'hDDF; // darkgrey
        5'b01100: cl_to_vga = 12'h0FF; // cyan
        5'b01101: cl_to_vga = 12'hF0F; // magenta
        5'b01110: cl_to_vga = 12'hFF0; // yellow
        5'b01111: cl_to_vga = 12'hFC8; // orange
        5'b10000: cl_to_vga = 12'hF0F; // pink
        5'b10001: cl_to_vga = 12'h9F9; // greenyellow
        5'b11111: cl_to_vga = 12'hFFF; // white
        default : cl_to_vga = 12'h000; // black
    endcase
end

endmodule
