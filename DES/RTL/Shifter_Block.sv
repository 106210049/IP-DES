module Shifter_Block(
  input logic clk, rst_n, key_process, shift_left_1, shift_right_1, decipher_process,
  input logic [27:0] cin,din,
  output logic [27:0] cn,dn
);
  always_ff@(posedge clk or negedge rst_n)	begin
    if(!rst_n)	begin
      cn<=0;
      dn<=0;
    end
    if(decipher_process)	begin
      if(shift_right_1)	begin
        cn	<=  {cin[0], cin[27:1]};
		dn	<=  {din[0], din[27:1]};
      end
      else	begin
        cn	<=  {cin[1:0], cin[27:2]};
		dn	<=  {din[1:0], din[27:2]};
      end
    end
      else	begin
        if(key_process)	begin
          if(shift_left_1)	begin
            cn	<=  {cin[26:0], cin[27]};
			dn	<=  {din[26:0], din[27]};
          end
          else	begin
            cn	<=  {cin[25:0], cin[27:26]};
			dn	<=  {din[25:0], din[27:26]};
          end
        end
        else begin
          cn<=cn;
          dn<=dn;
        end
      end
  end
endmodule