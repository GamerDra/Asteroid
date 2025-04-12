module vga_sync(
    input  wire clk,       // Expecting 50 MHz, then internally divided to 25 MHz
    input  wire on_sw,     // Active-high enable (or reset release)
    output wire hsync, vsync,
    output wire video_on,
    output wire [10:0] pixel_x,
    output wire [10:0] pixel_y
);

    //----------------------------------------------------------------
    // Standard 640×480@60 Hz Timing (25 MHz pixel clock)
    //----------------------------------------------------------------
    // Horizontal:
    //   Visible (HD)   = 640
    //   Front Porch (HF)= 16
    //   Sync Pulse (HS)= 96
    //   Back Porch (HB)= 48
    //   Total          = 800
    localparam HD = 640;
    localparam HF = 16;   // front porch
    localparam HS = 96;   // horizontal sync pulse
    localparam HB = 48;   // back porch
    // Vertical:
    //   Visible (VD)   = 480
    //   Front Porch (VF)= 10
    //   Sync Pulse (VS)= 2
    //   Back Porch (VB)= 33
    //   Total          = 525
    localparam VD = 480;
    localparam VF = 10;   // front porch
    localparam VS = 2;    // vertical sync pulse
    localparam VB = 33;   // back porch

    // Total counts (minus 1, since counters go 0..799 or 0..524)
    localparam H_TOTAL = HD + HF + HS + HB; // = 800
    localparam V_TOTAL = VD + VF + VS + VB; // = 525

    //----------------------------------------------------------------
    // Internal signals and registers
    //----------------------------------------------------------------

    // Divide incoming clock by 2 => ~25 MHz pixel enable (if clk=50 MHz)
    reg  mod2_reg;
    wire mod2_next;
    wire pixel_tick;  // Enable tick at 25 MHz

    // Counters
    reg [10:0] h_count_reg, h_count_next;
    reg [10:0] v_count_reg, v_count_next;

    // Sync signals
    reg h_sync_reg, v_sync_reg;
    wire h_sync_next, v_sync_next;

    // End-of-line/frame signals
    wire h_end = (h_count_reg == H_TOTAL - 1); // 799
    wire v_end = (v_count_reg == V_TOTAL - 1); // 524

    //----------------------------------------------------------------
    // Sequential: Divide clock + update counters + sync registers
    //----------------------------------------------------------------
    always @(posedge clk) begin
        if (!on_sw) begin
            // Reset
            mod2_reg   <= 1'b0;
            h_count_reg <= 11'd0;
            v_count_reg <= 11'd0;
            h_sync_reg  <= 1'b0;
            v_sync_reg  <= 1'b0;
        end
        else begin
            // Toggle-divide for 25 MHz enable
            mod2_reg <= mod2_next;
            // Update counters once every pixel tick (25 MHz)
            h_count_reg <= h_count_next;
            v_count_reg <= v_count_next;
            // Latch next sync states
            h_sync_reg  <= h_sync_next;
            v_sync_reg  <= v_sync_next;
        end
    end

    //----------------------------------------------------------------
    // Combinational: Next-state logic
    //----------------------------------------------------------------

    // Toggle mod2_reg each clock => 25 MHz pixel enable
    assign mod2_next  = ~mod2_reg;
    assign pixel_tick = mod2_reg;  // only true every other clock edge

    // Horizontal counter
    always @* begin
        if (pixel_tick) begin
            if (h_end)
                h_count_next = 11'd0;
            else
                h_count_next = h_count_reg + 1'b1;
        end 
        else begin
            h_count_next = h_count_reg; // hold
        end
    end

    // Vertical counter
    always @* begin
        if (pixel_tick && h_end) begin
            if (v_end)
                v_count_next = 11'd0;
            else
                v_count_next = v_count_reg + 1'b1;
        end
        else begin
            v_count_next = v_count_reg; // hold
        end
    end

    //----------------------------------------------------------------
    // Generate HSYNC and VSYNC (ACTIVE-LOW typically)
    //----------------------------------------------------------------
    // Standard approach for 640×480:
    //   HSYNC active in [HD+HF .. HD+HF+HS-1] => 656..751
    assign h_sync_next = (h_count_reg >= (HD + HF)) &&
                         (h_count_reg <  (HD + HF + HS));

    //   VSYNC active in [VD+VF .. VD+VF+VS-1] => 490..491
    assign v_sync_next = (v_count_reg >= (VD + VF)) &&
                         (v_count_reg <  (VD + VF + VS));

    // If your monitor expects active-low sync pulses, invert them:
    assign hsync = ~h_sync_reg;
    assign vsync = ~v_sync_reg;

    //----------------------------------------------------------------
    // Video ON region
    //----------------------------------------------------------------
    // True only when within the visible area (0..639, 0..479)
    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);

    // Expose counters as pixel coordinates
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule
