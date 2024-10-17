module decode (
    input   wire            I_sys_clk,
    input   wire            I_sys_rst,
    input   wire            I_Encode_A,
    input   wire            I_Encode_B,
    input   wire            I_Encode_Z,

    output  wire    [31:0]  O_Decode_data

);
    
/*
    一种方案就是A,B相上升下降沿相或，还有一个修正部分，当Z相有
*/
reg     [31:0]      R_Decode_data;

reg                 R_Encode_A;
reg     [1:0]       R_Encode_A_2r;
wire                S_Encode_A_posedge;
wire                S_Encode_A_negedge;
reg     [31:0]      R_A_pos_cnt;
reg     [31:0]      R_A_neg_cnt;              

wire                S_Encode_B_posedge;
wire                S_Encode_B_negedge;
reg                 R_Encode_B;
reg     [1:0]       R_Encode_B_2r;
reg     [31:0]      R_B_pos_cnt;
reg     [31:0]      R_B_neg_cnt;  

reg     [2:0]       R_Encode_Z_3r;
wire                R_Encode_Z_posedge;

wire    [1:0]       R_Encode_AB;
reg     [1:0]       R_Encode_AB_r;

assign  R_Encode_AB = {R_Encode_A,R_Encode_B};
/*如果为顺时针，R_Motor_Dir==0,如果为逆时针，R_Motor_Dir == 1*/
reg                 R_Motor_Dir;

always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_Encode_AB_r <= 2'b0;
    end else begin
        R_Encode_AB_r <= R_Encode_AB
    end
end
always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_Motor_Dir <= 1'd0;
    end else begin
        if(R_Encode_AB_r == 2'b11)begin
            if(R_Encode_AB == 2'b01)begin
                R_Motor_Dir = 1'b1;
            end else begin
                R_Motor_Dir = 1'b0;
            end
        end
    end
end



/*检测Encode上升沿与下降沿*/
always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_Encode_A_2r <= 2'b0;
    end else begin
        R_Encode_A_2r <= {R_Encode_A_2r[0],I_Encode_A};
    end
end
assign S_Encode_A_posedge = ~R_Encode_A_2r[1] & R_Encode_A_2r[0];
assign S_Encode_A_negedge = R_Encode_A_2r[1] & ~R_Encode_A_2r[0];


always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_Encode_B_2r <= 2'b0;
    end else begin
        R_Encode_B_2r <= {R_Encode_B_2r[0],I_Encode_B};
    end
end
assign S_Encode_B_posedge = ~R_Encode_B_2r[1] & R_Encode_B_2r[0];
assign S_Encode_B_negedge = R_Encode_B_2r[1] & ~R_Encode_B_2r[0];




always @(posedge ClkB or negedge rst_n2 ) begin
    if(!rst_n2)begin
        R_Encode_Z_3r <= 3'b0;
    end else begin
        R_Encode_Z_3r <= {R_Encode_Z_3r[1:0],I_Encode_Z};
        //第一拍，可能产生亚稳态//第二排，几乎不会亚稳态//第三拍，作为检测R_Encode_Z_3r[1]上升沿的辅助信号使用
    end
end
assign R_Encode_Z_posedge = R_Encode_Z_3r[1] && (~R_Encode_Z_3r[2]);



always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_A_pos_cnt <= 'd0;
    end else if(S_Encode_A_posedge)begin
        R_A_pos_cnt <= R_A_pos_cnt + 'd1
    end else begin
        R_A_pos_cnt <= R_A_pos_cnt;
    end
end
always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_A_neg_cnt <= 'd0;
    end else if(S_Encode_A_negedge)begin
        R_A_neg_cnt <= R_A_neg_cnt + 'd1
    end else begin
        R_A_neg_cnt <= R_A_neg_cnt;
    end
end
always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_B_pos_cnt <= 'd0;
    end else if(S_Encode_B_posedge)begin
        R_B_pos_cnt <= R_B_pos_cnt + 'd1
    end else begin
        R_B_pos_cnt <= R_B_pos_cnt;
    end
end
always @(posedge I_sys_clk or posedge I_sys_rst) begin
    if(I_sys_rst)begin
        R_B_neg_cnt <= 'd0;
    end else if(S_Encode_B_negedge)begin
        R_B_neg_cnt <= R_B_neg_cnt + 'd1
    end else begin
        R_B_neg_cnt <= R_B_neg_cnt;
    end
end
assign O_Decode_data = R_A_pos_cnt + R_A_neg_cnt + R_B_pos_cnt + R_B_neg_cnt;


endmodule