class env;

  agent      agt;
  scoreboard scb;

  mailbox mon_to_sb;

  function new(virtual des_if vif);

    mon_to_sb = new();

    agt = new(vif, mon_to_sb);
    scb  = new(mon_to_sb);

  endfunction


  task run();

    // int expected_count;
    // expected_count = agt.gen.num_gen;
    // $display("[ENV] Starting environment...");
    // $display("[ENV] Expected transaction count = %0d", expected_count);

    fork : ENV_THREADS
      agt.run();
      scb.run();
    join_none

    // wait(scb.compare_cnt >= expected_count);
    // #10;
    // disable ENV_THREADS;

    // $finish;

  endtask

  task report();
    scb.report();
  endtask

endclass