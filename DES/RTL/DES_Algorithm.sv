`include "IP.sv"
`include "DES_function.sv"
`include "IP_1.sv"

module DES_Algorithm(
    input logic        clk,
    input logic        rst_n,
    input logic        encipher_process,
    input logic        decipher_process,
  	input logic 		  rkey_en,
    input logic [63:0] des_data,
    input logic [47:0] round_key,
    input logic [3:0]  r_counter,

    output logic [63:0] desc_result
);

    // ===== Internal signals =====
    logic [31:0] ln;
    logic [31:0] rn;
    logic [31:0] l_input;
    logic [31:0] r_input;
    logic [31:0] f_value;

    // ===== Initial Permutation - IP =====
    IP ip_inst (
        .des_data(des_data),
        .r_counter(r_counter),
        .encipher_process(encipher_process),
        .rkey_en(rkey_en),
        .ln(ln),
        .rn(rn),
        .l_input(l_input),
        .r_input(r_input)
    );

    // ===== DES Function =====
    DES_function des_inst (
        .r_input(r_input),
        .round_key(round_key),
        .f_value(f_value)
    );

    // ===== Final Permutation - IP_1 =====
    IP_1 ip_1_inst (
        .clk(clk),
        .rst_n(rst_n),
        .encipher_process(encipher_process),
        .decipher_process(decipher_process),
        .l_input(l_input),
        .r_input(r_input),
        .f_value(f_value),
        .rn(rn),
        .ln(ln),
        .desc_result(desc_result)
    );

endmodule
