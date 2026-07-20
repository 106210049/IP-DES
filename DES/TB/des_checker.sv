program des_checker(des_if vif);

    property p_des_ready;
        @(vif.clk) disable iff (!vif.rst_n) 
        (!tb_top_des.dut.controller_inst.key_process && 
        !tb_top_des.dut.controller_inst.encipher_process) 
        |-> vif.desc_ready;
    endproperty
    ASSERT_DESC_READY:
    assert property (p_des_ready) 
    $display("[PASS] ASSERT DES READY");
    else $error("[DES_CHECKER] desc_ready assertion failed at time %0t", $time);


endprogram