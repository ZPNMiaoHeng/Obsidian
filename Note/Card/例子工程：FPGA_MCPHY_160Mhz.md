#card 

# 更改内容
## AXI 激励
###### axi 数据格式
- 更改文件路径：
``` bash
/fpga_mcphy_vcs_160Mhz/ddr4_0_ex/imports/ddr4_v2_2_boot_mode_gen.sv
```
- 更改内容：
```verilog
assign instr_mem[0] = {1'b1, 40'h00_8000_0000, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MAX, C_AXI_BURST_SIZE_MAX };
assign instr_mem[1] = {1'b1, 40'h00_8000_0040, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MAX, C_AXI_BURST_SIZE_MAX };
assign instr_mem[2] = {1'b1, 40'h00_8000_0080, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MAX, C_AXI_BURST_SIZE_MAX };
assign instr_mem[3] = {1'b1, 40'h00_8000_00C0, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MAX, C_AXI_BURST_SIZE_MAX };
assign instr_mem[4] = {1'b1, 40'h00_8000_0100, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MAX, C_AXI_BURST_SIZE_MAX };
```
###### axi写数据
- 更改路径：
``` bash
fpga_ddr_1206/ddr4_0_ex/imports/ddr4_v2_2_data_gen.sv
```
- 更改内容：
```verilog
    u_prbs_data_gen(
    .clk(clk),
    .data_en(data_en),
    .data_pattern(data_pattern),
    .pattern_init(pattern_init),
    .prbs_seed_i({{(32 -C_AXI_ID_WIDTH){1'b0}},prbs_seed_i} + i),
    .data_o() 
//    .data_o(data_out[(i*32)+:32]) 
  );
    
    assign data_out = 256'h0000_0000_1111_1111_2222_2222_3333_3333_4444_4444_5555_5555_6666_6666_7777_7777;
```

## axi_gen
###### axi_addr添加复位初值，强制发出len=1命令.
- 存放路径：`/ddr4_0_ex/imports/ddr4_v2_2_axi_opcode_gen.sv`
- 更改内容：
```verilog
//{{{
// miaoheng: add addr_r reset!!
// Only use first test!!!
always @(posedge clk) begin
    if(tg_rst) begin
        instr_axi_addr_r <= #TCQ 'b0;
    end
    else if(tg_opcode_gen_idle_s && opcode_gen_start)begin
    instr_axi_addr_r <= #TCQ instr_axi_addr;
  end 
end

always @(posedge clk) begin
  if(tg_opcode_gen_idle_s && opcode_gen_start)begin
//    instr_axi_addr_r <= #TCQ instr_axi_addr;
    instr_axi_length_r <= #TCQ instr_axi_length;
    instr_axi_size_r <= #TCQ instr_axi_size;
    instr_axi_burst_r <= #TCQ instr_axi_burst;
    instr_axi_strb_pattern_r <= #TCQ (instr_axi_burst == C_AXI_BURST_WRAP)? C_STRB_PATTERN_DEFAULT : instr_axi_strb_pattern; // for WRAP Burst back ground data is not proper due to instr_axi_strb_pattern and fixed to C_STRB_PATTERN_DEFAULT which is working fine
  end 
end
//}}}


//{{{
// miaoheng: first test.
// wire ecc_prevent_bg_write  = ((SEND_NBURST== 1) ? 1'b1: ((((APP_DATA_WIDTH > C_AXI_DATA_WIDTH) && partial_len) == 1)? 1'b1 : 1'b0)) && (ECC == "ON");
wire ecc_prevent_bg_write  = 1'b0;
//}}}

```
## tb
###### tb
- 存放路径：`/home/data1/xiongxinzhong/workspace/test_by_miaoheng/demo/fpga_mcphy_160Mhz/ddr4_0_ex/imports/sim_tb_top.sv`
- 更改内容：
```verilog
  initial begin
     sys_rst = 1'b0;
     #200
     sys_rst = 1'b1;
     en_model = 1'b0; 
     #5 en_model = 1'b1;
     #200;
     sys_rst = 1'b0;
     #100;
     #30us;         // 添加结束时间
     $finish;
  end

```

``` verilog
initial
begin
    $fsdbDumpfile("fpga_mcphy_160Mhz_tb.fsdb");
    $fsdbDumpvars();
endS
```