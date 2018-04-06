`timescale 1ns/1ps

module tb_fifo;
    localparam DATA_WIDTH = 8;
    
    logic clk;
    logic reset;
    
    logic write_en, read_en, full, empty;
    logic [DATA_WIDTH-1:0] input_data;
    logic [DATA_WIDTH-1:0] output_data;
    logic [DATA_WIDTH-1:0] write_counter;
    logic [DATA_WIDTH-1:0] read_counter;
    
    //Initialize clock, reset and end simulation
    initial begin
        clk <= 1'b0; //Initialize clock 
        write_counter <= 1'b0;
        read_counter <= 1'b0;
        reset <= 1'b0;
        #30;
        reset <= 1'b1;
        #30;
        reset <= 1'b0;
        #10000;
        $display ("Simulation Complete");
        $stop;
    end
    
    //Clock generator
    always begin //always run
        #10; //gets the clock to flip with 10 x 1 ns        
        clk <= !clk;
    end
    
    fifo # (
        .ADDR_WIDTH(2         ),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_dut (
        .clk     (clk        ),
        .reset   (reset      ),
        .din     (input_data ),
        .dout    (output_data),
        .write_en(write_en   ),
        .read_en (read_en    ),
        .full    (full       ),
        .empty   (empty      ),
        .level   (           )
    );
    
    // FIFO Writer
    always @ (posedge clk) begin 
        if(reset) begin
            write_counter <= '0;
            write_en <= 1'b0;
        end else begin
            write_en <= 1'b0;
            
            if (!full && write_counter < 8'd100) begin
                write_en <= 1'b1;
            end
            
            if (write_en) begin
                write_counter <= write_counter + 1'b1; //increment
            end
        end
    end
    
    assign input_data = write_counter; // Wire input_data to write_counter directly
    
    // FIFO Reader and Verifier
    always @ (posedge clk) begin
        if (reset) begin
            read_counter <= '0;
            read_en <= 1'b0;
        end else begin
            read_en <= 1'b0;
            
            if (!empty) begin
                read_en <= 1'b1;
                read_counter <= read_counter + 1'b1;
                
                if (read_counter != output_data) begin
                    $display ("Mismatch"); 
                    $stop;
                end
            end
        end
      end
endmodule


