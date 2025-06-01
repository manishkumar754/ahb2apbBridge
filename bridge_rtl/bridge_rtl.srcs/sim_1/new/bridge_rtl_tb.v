`timescale 1ns / 1ps

module bridge_rtl_tb();
    reg hclk, hresetn, hselapb, hwrite;
    reg [1:0] htrans;
    reg [31:0] haddr, hwdata;
    reg [31:0] prdata;
    wire [31:0] paddr, pwdata;
    wire psel, penable, pwrite;
    wire hresp, hready;
    wire [31:0] hrdata;

    bridge_rtl dut (
        .hclk(hclk),
        .hresetn(hresetn),
        .hselapb(hselapb),
        .hwrite(hwrite),
        .htrans(htrans),
        .haddr(haddr),
        .hwdata(hwdata),
        .prdata(prdata),
        .paddr(paddr),
        .pwdata(pwdata),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .hresp(hresp),
        .hready(hready),
        .hrdata(hrdata)
    );

    // Clock generation
    initial begin
        hclk = 0;
        forever #10 hclk = ~hclk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        hresetn = 0;
        hselapb = 0;
        hwrite = 0;
        htrans = 0;
        haddr = 0;
        hwdata = 0;
        prdata = 0;
        
        // Reset sequence
        #20;
        hresetn = 1;
        
        // Test 1: Single read transfer
        #20;
        hselapb = 1;
        htrans = 2'b10;  // NONSEQ
        haddr = 32'h4000_0000;
        #20;
        prdata = 32'h1234_5678;
        hselapb = 0;
        htrans = 0;
        
        // Test 2: Single write transfer
        #40;
        hselapb = 1;
        htrans = 2'b10;  // NONSEQ
        hwrite = 1;
        haddr = 32'h4000_0010;
        hwdata = 32'hCAFE_BABE;
        #20;
        hselapb = 0;
        htrans = 0;
        hwrite = 0;
        
        // Test 3: Back-to-back transfers
        #40;
        // Read1
        hselapb = 1;
        htrans = 2'b10;
        haddr = 32'h4000_0020;
        #20;
        prdata = 32'h1111_2222;
        // Immediately follow with write
        htrans = 2'b10;
        hwrite = 1;
        haddr = 32'h4000_0030;
        hwdata = 32'hDEAD_BEEF;
        #20;
        prdata = 32'h3333_4444;  // New read data
        hselapb = 0;
        htrans = 0;
        
        // End test
        #100 $finish;
    end

    // Monitoring
    always @(posedge hclk) begin
        $display("[%0t] STATE: %d, HREADY: %b, PADDR: %h, HRDATA: %h", 
                 $time, dut.present_state, hready, paddr, hrdata);
    end
endmodule