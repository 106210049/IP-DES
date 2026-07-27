program des_checker(des_if vif);

    property p_des_ready;
        @(vif.clk) disable iff (!vif.rst_n) 
        (!tb_top_des.dut.controller_inst.key_process && 
        !tb_top_des.dut.controller_inst.encipher_process) 
        |-> vif.desc_ready;
    endproperty
    ASSERT_DESC_READY:
    assert property (p_des_ready) 
    $display("[SVA][PASS] ASSERT DES READY");
    else $error("[SVA][FAIL] desc_ready assertion failed at time %0t", $time);
    cover property (p_des_ready)
        $display("[SVA][COVER] ASSERT DES READY");

    property p_data_valid;
        @(vif.clk) disable iff (!vif.rst_n)
        $rose(vif.desc_ready)
        |-> (vif.desc_result != 0);
    endproperty
    ASSERT_DATA_VALID:
    assert property (p_data_valid)
    $display("[SVA][PASS] ASSERT DATA VALID = %016h", vif.desc_result);
    else $error("[SVA][FAIL] DATA MUST BE NON-ZERO");
    cover property (p_data_valid)
        $display("[SVA][COVER] ASSERT DATA VALID");
endprogram