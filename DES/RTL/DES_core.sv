`include "DES_Algorithm.sv"
`include "Key_Schedule.sv"
`include "DES_Controller.sv"

module DES_core(
    input logic clk,
    input logic rst_n,
    input logic des_encipher_en,
    input logic des_decipher_en,
    input logic [63:0] des_data,
    input logic [63:0] des_key_in,

    output logic desc_ready,
    output logic [63:0] desc_result
);

    // ===== Internal Signals =====
    logic [47:0] round_key;
   
    logic key_process;
    logic rkey_en;
    logic shift_right_1;
    logic shift_left_1;
    logic decipher_process;
    logic encipher_process;
    logic [3:0] r_counter;

    // ===== DES Algorithm =====
    DES_Algorithm des_algorithm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .encipher_process(encipher_process),
        .decipher_process(decipher_process),
        .des_data(des_data),
      	.rkey_en(rkey_en),
        .round_key(round_key),
        .r_counter(r_counter),
        .desc_result(desc_result)
    );

    // ===== Key Schedule =====
    Key_Schedule key_schedule_inst (
        .clk(clk),
        .rst_n(rst_n),
        .des_key_in(des_key_in),
        .shift_left_1(shift_left_1),
        .shift_right_1(shift_right_1),
        .decipher_process(decipher_process),
        .rkey_en(rkey_en),
        .key_process(key_process),
        .round_key(round_key)
    );

    // ===== DES Controller =====
    DES_Controller controller_inst (
        .clk(clk),
        .rst_n(rst_n),
        .des_encipher_en(des_encipher_en),
        .des_decipher_en(des_decipher_en),
        .key_process(key_process),
        .rkey_en(rkey_en),
        .shift_right_1(shift_right_1),
        .shift_left_1(shift_left_1),
        .decipher_process(decipher_process),
        .encipher_process(encipher_process),
        .r_counter(r_counter),
        .desc_ready(desc_ready)
    );

endmodule
