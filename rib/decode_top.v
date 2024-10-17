module decode_top ();

reg I_sys_clk;
reg I_sys_rst;
reg I_Encode_A;
reg I_Encode_B;
reg I_Encode_Z;
wire [31:0] O_Decode_data;

decode uut(
    .I_sys_clk          (I_sys_clk),
    .I_sys_rst          (I_sys_rst),
    .I_Encode_A         (I_Encode_A),
    .I_Encode_B         (I_Encode_B),
    .I_Encode_Z         (I_Encode_Z),

    .O_Decode_data      (O_Decode_data)
);

always #5 I_sys_clk = ~I_sys_clk;

initial begin
    I_sys_rst = 1;
    #1000
    I_sys_rst = 0;
end
initial begin
    I_Encode_A = 0; // 延迟 2.5 时间单位后开始
    forever #5000 I_Encode_A = ~I_Encode_A; // 继续按照与相同的频率反转
end
initial begin
    #50 I_Encode_B = 0; // 延迟 2.5 时间单位后开始
    forever #5000 I_Encode_B = ~I_Encode_B; // 继续按照与相同的频率反转
end


initial begin
    I_Encode_Z = 0; // 延迟 2.5 时间单位后开始
    forever #50000 I_Encode_A = ~I_Encode_A; // 继续按照与相同的频率反转
end

endmodule