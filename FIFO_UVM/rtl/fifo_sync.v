module fifo_sync #(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input wr,
    input rd,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty
);

    // Memory array
    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
    
    // 4-bit pointers (MSB for full/empty detection)
    reg [3:0] write_pointer;
    reg [3:0] read_pointer;
    
    // Full and empty flag generation
    assign full = (read_pointer == {~write_pointer[3], write_pointer[2:0]});
    assign empty = (read_pointer == write_pointer);
    
    // Write operation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            write_pointer <= 4'b0;
        end else if (wr && !full) begin
            fifo[write_pointer[2:0]] <= data_in;
            write_pointer <= write_pointer + 1'b1;
        end
    end
    
    // Read operation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            read_pointer <= 4'b0;
            data_out <= 8'b0;
        end else if (rd && !empty) begin
            data_out <= fifo[read_pointer[2:0]];
            read_pointer <= read_pointer + 1'b1;
        end
    end
    
endmodule
