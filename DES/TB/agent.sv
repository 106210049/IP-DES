class agent;

  driver    drv;
  monitor   mon;
  generator gen;

  mailbox gen_to_drv;

  virtual des_if vif;

  function new(
    virtual des_if vif,
    mailbox mon_to_sb
  );

    this.vif = vif;

    gen_to_drv = new();

    gen = new(gen_to_drv);
    drv = new(gen_to_drv, vif);
    mon = new(mon_to_sb, vif);

  endfunction

  function void cfg_gen(
    input int num_gen,
    input test_case tc
  );
    gen.num_gen = num_gen;
    gen.test = tc;

  endfunction

  task run();

    fork
      gen.run();
      drv.run();
      mon.run();
    join_none

  endtask

endclass