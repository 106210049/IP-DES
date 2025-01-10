// Module for Encryption Round Counter
module EncryptionRoundCounter(
    input wire clk,
    input wire rst_n,
    input wire key_process,
    output reg [3:0] r_counter
);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            r_counter <= 4'd0;
        else if (key_process)
            r_counter <= r_counter + 4'd1;
    end

endmodule
