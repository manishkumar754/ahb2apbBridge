`timescale 1ns / 1ps

module bridge_rtl(
    input        hclk,        // AHB Clock
    input        hresetn,     // AHB Reset (active low)
    input        hselapb,     // AHB Peripheral Select
    input        hwrite,      // AHB Write/Read Control
    input  [1:0] htrans,      // AHB Transfer Type
    input  [31:0] haddr,      // AHB Address Bus
    input  [31:0] hwdata,     // AHB Write Data
    input  [31:0] prdata,     // APB Read Data
    output reg [31:0] paddr,  // APB Address
    output reg [31:0] pwdata, // APB Write Data
    output reg psel,          // APB Peripheral Select
    output reg penable,       // APB Enable
    output reg pwrite,        // APB Write/Read Control
    output reg hresp = 1'b0,  // AHB Response (0 = OKAY)
    output reg hready,        // AHB Ready
    output reg [31:0] hrdata  // AHB Read Data
);
    
    // FSM States
    parameter IDLE     = 3'b000;
    parameter READ     = 3'b001;
    parameter WWAIT    = 3'b010;
    parameter WRITE    = 3'b011;
    parameter RENABLE  = 3'b100;
    parameter WENABLE  = 3'b101;
    
    reg [2:0] present_state, next_state;
    reg [31:0] haddr_temp, hwdata_temp;
    reg valid;
    
    // Valid transfer detection (NONSEQ only)
    always @(*) begin
        valid = hselapb && (htrans == 2'b10);  // Only NONSEQ starts transfers
    end
    
    // Synchronous state transition
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) present_state <= IDLE;
        else present_state <= next_state;
    end
    
    // Next state logic and output control
    always @(*) begin
        // Default outputs
        psel = 1'b0;
        penable = 1'b0;
        pwrite = 1'b0;
        hready = 1'b1;
        next_state = present_state;
        hresp = 1'b0;  // Always OKAY
        
        case (present_state)
            IDLE: begin
                if (valid) begin
                    if (hwrite) begin
                        next_state = WWAIT;
                        hready = 1'b0;  // Insert wait state for writes
                    end
                    else begin
                        next_state = READ;
                        hready = 1'b0;  // Insert wait state for reads
                    end
                end
            end
            
            READ: begin
                psel = 1'b1;
                paddr = haddr;
                pwrite = 1'b0;
                next_state = RENABLE;
            end
            
            RENABLE: begin
                psel = 1'b1;
                penable = 1'b1;
                paddr = haddr;
                pwrite = 1'b0;
                hrdata = prdata;
                
                if (valid) begin
                    if (hwrite) begin
                        next_state = WWAIT;
                        hready = 1'b0;
                    end
                    else begin
                        next_state = READ;
                        hready = 1'b0;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            
            WWAIT: begin
                haddr_temp = haddr;     // Latch address
                hwdata_temp = hwdata;   // Latch write data
                next_state = WRITE;
            end
            
            WRITE: begin
                psel = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                next_state = WENABLE;
            end
            
            WENABLE: begin
                psel = 1'b1;
                penable = 1'b1;
                paddr = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                
                if (valid) begin
                    if (hwrite) begin
                        next_state = WWAIT;
                        hready = 1'b0;
                    end
                    else begin
                        next_state = READ;
                        hready = 1'b0;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule