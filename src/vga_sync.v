module vga_sync(
    input  wire clk,    // 65 MHz pixel clock
    input  wire on_sw,  // Active-high reset/enable
    output wire hsync, vsync,
    output wire video_on,
    output wire [10:0] pixel_x,
    output wire [10:0] pixel_y
);

    //=============================
    // 1024×768@60 Hz Timing
    //=============================
    // Horizontal:
    //   Visible (HD)   = 1024
    //   Front Porch (HF)= 24
    //   Sync Pulse (HS)= 136
    //   Back Porch (HB)= 160
    //   Total          = 1344
    localparam HD = 1024;
    localparam HF = 24;
    localparam HS = 136;
    localparam HB = 160;
    localparam H_TOTAL = HD + HF + HS + HB; // = 1344

    // Vertical:
    //   Visible (VD)   = 768
    //   Front Porch (VF)= 3
    //   Sync Pulse (VS)= 6
    //   Back Porch (VB)= 29
    //   Total          = 806
    localparam VD = 768;
    localparam VF = 3;
    localparam VS = 6;
    localparam VB = 29;
    localparam V_TOTAL = VD + VF + VS + VB; // = 806

    //=============================
    // Internal Registers
    //=============================
    reg [10:0] h_count_reg, v_count_reg;
    wire       h_end, v_end;
    reg        h_sync_reg, v_sync_reg;

    //=============================
    // End-of-line/frame signals
    //=============================
    assign h_end = (h_count_reg == H_TOTAL - 1); // 1343
    assign v_end = (v_count_reg == V_TOTAL - 1); // 805

    //=============================
    // Sequential Logic
    //=============================
    always @(posedge clk) begin
        if (!on_sw) begin
            // Synchronous reset (active-low on_sw)
            h_count_reg <= 0;
            v_count_reg <= 0;
            h_sync_reg  <= 0;
            v_sync_reg  <= 0;
        end
        else begin
            //------------- H Counter -------------
            if (h_end) begin
                h_count_reg <= 0;
                //--------- V Counter -------------
                if (v_end)
                    v_count_reg <= 0;
                else
                    v_count_reg <= v_count_reg + 1;
            end
            else begin
                h_count_reg <= h_count_reg + 1;
            end

            //------------- HSYNC, VSYNC -------------
            // HSYNC active in [HD+HF .. HD+HF+HS-1] => [1024+24..1024+24+136-1] => [1048..1183]
            h_sync_reg <= (h_count_reg >= (HD + HF)) &&
                          (h_count_reg <  (HD + HF + HS));

            // VSYNC active in [VD+VF .. VD+VF+VS-1] => [768+3..768+3+6-1] => [771..776]
            v_sync_reg <= (v_count_reg >= (VD + VF)) &&
                          (v_count_reg <  (VD + VF + VS));
        end
    end

    //=============================
    // Output Assignments
    //=============================
    // If your monitor expects active-low sync pulses, invert them:
    assign hsync     = ~h_sync_reg;
    assign vsync     = ~v_sync_reg;

    // video_on is high only in the visible area (0..1023 x 0..767)
    assign video_on  = (h_count_reg < HD) && (v_count_reg < VD);

    // Expose the counters
    assign pixel_x   = h_count_reg;
    assign pixel_y   = v_count_reg;

endmodule
