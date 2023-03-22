// Simple verilog file
// Compliant with IEEE1800-2005
module test (
    input logic clk,
    output logic [3:0] q
);

  always_ff @(posedge clk) begin : proc_gen_data
    q <= q + 1'b1;
  end

  initial begin : hello_world
    $display("Hello world");
  end

endmodule : test
