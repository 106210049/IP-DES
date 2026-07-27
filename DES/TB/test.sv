program test(des_if vif);

  env env_o;
  // -----------------------------
  // Runtime params
  // -----------------------------
  string testname;
  int    timeout;

  initial begin

    timeout  = 2000;
    //----------------------------------------
    // Override via plusargs
    //----------------------------------------
    void'($value$plusargs("TESTNAME=%s", testname));
    void'($value$plusargs("TIMEOUT=%d", timeout));

    $display("[TEST] TESTNAME=%s TIMEOUT=%0d", testname, timeout);
    
    env_o = new(vif);

    case (testname)
      "ENCRYPTION" : env_o.agt.cfg_gen(1, ENCRYPTION);
      "DECRYPTION" : env_o.agt.cfg_gen(1, DECRYPTION);
      "RANDOM"     : env_o.agt.cfg_gen(10, RANDOM);
      default: begin
        $display("[TEST][ERROR] Invalid TESTNAME=%s", testname);
        $finish;
      end
    endcase

    env_o.run();
    // #(timeout);
    wait (env_o.scb.compare_cnt >= env_o.agt.gen.num_gen);
    #10;
    //----------------------------------------
    // Report + Finish
    //----------------------------------------
    $display("[TEST] TIMEOUT reached");

    env_o.report();
    $finish;
  end

endprogram