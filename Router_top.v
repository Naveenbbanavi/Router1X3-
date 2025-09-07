 
//Design Code: 
module router_top(input clock, 
resetn, 
read_enb_0, 
read_enb_1, 
read_enb_2, 
pkt_valid, 
input [7:0] data_in, 
output vld_out_0, 
vld_out_1, 
vld_out_2, 
err, 
busy, 
output [7:0] data_out_0, 
data_out_1, 
data_out_2); 
 
wire [2:0] write_enb; 
wire [7:0] dout; 
wire 
parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,detect_add,l 
d_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,empty_0,empty_1,empty_ 
2,full_0,full_1,full_2; 
 
router_fsm 
FSM(clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full 
,low_pkt_valid,empty_0,empty_1,empty_2,data_in[1:0],busy,detect_add,ld_state,laf_state, 
full_state,write_enb_reg,rst_int_reg,lfd_state); 
 
router_sync 
Synchronizer(clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,emp 
ty_0,empty_1,empty_2,full_0,full_1,full_2,data_in[1:0],fifo_full,soft_reset_0,soft_rese 
t_1,soft_reset_2,vld_out_0,vld_out_1,vld_out_2,write_enb); 
 
router_reg 
Register(clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,ful 
l_state,lfd_state,data_in,parity_done,low_pkt_valid,err,dout); 
 
router_fifo 
FIFO_0(clock,resetn,write_enb[0],soft_reset_0,read_enb_0,lfd_state,dout,empty_0, 
full_0,data_out_0); 
 
router_fifo 
FIFO_1(clock,resetn,write_enb[1],soft_reset_1,read_enb_1,lfd_state,dout,empty_1, 
full_1,data_out_1); 
 
router_fifo 
FIFO_2(clock,resetn,write_enb[2],soft_reset_2,read_enb_2,lfd_state,dout,empty_2, 
full_2,data_out_2); 
 
endmodule 
 
 
//Simulation Code: 
module router_top_tb(); 
reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid; 
reg [7:0] data_in; 
wire vld_out_0,vld_out_1,vld_out_2,err,busy; 
wire [7:0] data_out_0,data_out_1,data_out_2;   
event e1,e2; 
parameter T = 10; 
router_top DUT(clock, 
resetn, 
read_enb_0, 
read_enb_1, 
read_enb_2, 
pkt_valid, 
data_in, 
vld_out_0, 
vld_out_1, 
vld_out_2, 
err, 
busy, 
data_out_0, 
data_out_1, 
data_out_2); 
 
initial 
begin 
clock = 1'b0; 
forever #(T/2) clock = ~clock; 
end 
 
task initialize; 
begin 
resetn = 1'b1; 
read_enb_0 = 0; 
read_enb_1 = 0; 
read_enb_2 = 0; 
pkt_valid = 0; 
data_in = 0; 
end 
endtask 
 
task reset_ip; 
begin 
@(negedge clock); 
resetn = 1'b0; 
@(negedge clock); 
resetn = 1'b1; 
end 
endtask 
 
task payload_14_15(input [5:0]d1,input [1:0]a1); 
reg [7:0] header, payload, parity; 
reg [5:0] payload_len; 
reg [1:0] addr; 
integer i; 
begin 
@(negedge clock); 
wait(!busy) 
@(negedge clock); 
parity = 0; 
payload_len = d1; 
addr = a1; 
header = {payload_len,addr}; 
parity = parity ^ header; 
pkt_valid = 1'b1; 
data_in = header; 
@(negedge clock); 
wait(!busy) 
for(i=0;i<payload_len;i=i+1) 
begin 
@(negedge clock); 
end 
endtask 
wait(!busy) 
payload = i; 
parity = parity ^ payload; 
data_in = payload; 
end 
wait(!busy) 
@(negedge clock); 
pkt_valid = 0; 
data_in = parity; 
 
task payload_16_17(input [5:0]d2,input [1:0]a2); 
reg [7:0] header, payload, parity; 
reg [5:0] payload_len; 
reg [1:0] addr; 
integer i; 
begin 
@(negedge clock); 
wait(!busy) 
parity = 0; 
payload_len = d2; 
addr = a2; 
header = {payload_len,addr}; 
parity = parity ^ header; 
@(negedge clock); 
pkt_valid = 1'b1; 
data_in = header; 
@(negedge clock); 
wait(!busy) 
for(i=0;i<payload_len;i=i+1) 
begin 
@(negedge clock); 
wait(!busy) 
payload = i; 
parity = parity ^ payload; 
data_in = payload; 
end ->e1; 
wait(!busy) 
@(negedge clock); 
pkt_valid = 0; 
data_in = parity; 
end 
endtask 
 
task random_packet(input [5:0]d3,input [1:0]a3); 
reg [7:0] header, payload, parity; 
reg [5:0] payload_len; 
reg [1:0] addr; 
integer i; 
begin ->e2; 
@(negedge clock); 
wait(!busy) 
parity = 0; 
payload_len = d3; 
addr = a3; 
header = {payload_len,addr}; 
parity = parity ^ header; 
@(negedge clock); 
pkt_valid = 1'b1; 
data_in = header; 
@(negedge clock); 
wait(!busy) 
for(i=0;i<payload_len;i=i+1) 
begin
@(negedge clock); 
wait(!busy) 
payload = i; 
parity = parity ^ payload; 
data_in = payload; 
end 
wait(!busy) 
@(negedge clock); 
pkt_valid = 0; 
data_in = parity; 
 
initial 
begin 
forever 
begin 
@(e1) 
begin 
@(negedge clock); 
read_enb_1 = 1'b1; 
wait(!vld_out_1) 
@(negedge clock); 
read_enb_1 = 0; 
end 
end 
end 
 
initial 
begin 
forever 
begin 
@(e2) 
begin 
wait(vld_out_2) 
@(negedge clock); 
read_enb_2 = 1'b1; 
wait(!vld_out_2) 
@(negedge clock); 
read_enb_2 = 0; 
end 
end 
end 
 
initial 
begin 
initialize; 
reset_ip; 
repeat (2) @(negedge clock); 
 
// Packet Size = 16bytes 
// DA-LFD-LD-LP-CPE-DA 
payload_14_15(6'd14,2'd0); 
@(negedge clock); 
read_enb_0 = 1'b1; 
wait(!vld_out_0) 
@(negedge clock); 
read_enb_0 = 0; 
#100; 
 
// Packet Size = 17bytes 
// DA-LFD-LD-LP-CPE-FFS-LAF-DA 
payload_14_15(6'd15,2'd0); 
@(negedge clock); 
wait(busy) 
@(negedge clock); 
35  
read_enb_0 = 1'b1; 
36  
wait(!vld_out_0) 
@(negedge clock); 
read_enb_0 = 0; 
#100; 
 
// Packet Size = 18bytes 
// DA-LFD-LD-FFS-LAF-LP-CPE-DA 
payload_16_17(6'd16,2'd1); 
wait(!vld_out_1) 
@(negedge clock); 
read_enb_1 = 0; 
#100; 
 
// Packet Size = 19bytes 
// DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA 
payload_16_17(6'd17,2'd1); 
wait(!vld_out_1) 
@(negedge clock); 
read_enb_1 = 0; 
#100; 
 
// Packet Size = 24bytes 
// DA-LFD-LD-LP-CPE-DA 
random_packet(6'd22,2'd2); 
wait(!vld_out_2) 
@(negedge clock); 
read_enb_2 = 0; 
#100; 
 
$finish; 
end 
initial 
$monitor("Data Input = %d, data_out_0 = %d, data_out_1 = %d, data_out_2 = %d, 
Busy = %b, Error = %b", 
data_in,data_out_0,data_out_1,data_out_2,busy,err); 
endmodule
