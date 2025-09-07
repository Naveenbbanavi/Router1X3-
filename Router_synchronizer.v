 //Design Code: 
module router_sync(input clock, 
resetn, 
detect_add, 
write_enb_reg, 
read_enb_0, 
read_enb_1, 
read_enb_2, 
empty_0, 
empty_1, 
empty_2, 
full_0, 
full_1, 
full_2, 
input [1:0] data_in, 
output reg fifo_full, 
soft_reset_0, 
soft_reset_1, 
soft_reset_2, 
output vld_out_0, 
vld_out_1, 
vld_out_2, 
output reg [2:0] write_enb); 
 
reg[1:0] fifo_addr; 
reg[4:0] timer_0,timer_1,timer_2; 
 
// Logic for storing address 
always@(posedge clock) 
begin 
if(!resetn) 
fifo_addr <= 0; 
else if(detect_add) 
fifo_addr <= data_in; 
end 
 
// Logic for fifo full status 
always@(*) 
begin 
if(!resetn) 
fifo_full = 0; 
else 
begin 
case(fifo_addr) 
2'b00 : fifo_full = full_0; 
2'b01 : fifo_full = full_1; 
2'b10 : fifo_full = full_2; 
default: fifo_full = 0; 
endcase 
end 
end 
 
// Logic for write enable 
always@(*) 
begin 
if(!resetn) 
write_enb = 0; 
else if(write_enb_reg) 
begin 
case(fifo_addr) 
2'b00 : write_enb = 3'b001; 
2'b01 : write_enb = 3'b010; 
9  
2'b10 : write_enb = 3'b100; 
default : write_enb = 3'b0; 
endcase 
end 
else 
write_enb = 0; 
end 
 
// Logic for valid out signal 
assign vld_out_0 = ~empty_0; 
assign vld_out_1 = ~empty_1; 
assign vld_out_2 = ~empty_2; 
 
// Logic for soft reset 0 
always@(posedge clock) 
begin 
if(!resetn) 
begin 
soft_reset_0 <= 0; 
timer_0 <= 0; 
end 
else if(~vld_out_0) 
begin 
soft_reset_0 <= 0; 
timer_0 <= 0; 
end 
else if(read_enb_0) 
begin 
soft_reset_0 <= 0; 
timer_0 <= 0; 
end 
else 
begin 
if(timer_0 == 5'd29) 
begin 
soft_reset_0 <= 1'b1; 
timer_0 <= 0; 
end 
else 
begin 
timer_0 <= timer_0 + 1'b1; 
soft_reset_0 <= 0; 
end 
end 
end 
 
// Logic for soft reset 1 
always@(posedge clock) 
begin 
if(!resetn) 
begin 
soft_reset_1 <= 0; 
timer_1 <= 0; 
end 
else if(~vld_out_1) 
begin 
soft_reset_1 <= 0; 
timer_1 <= 0; 
end 
else if(read_enb_1) 
begin 
soft_reset_1 <= 0; 
timer_1 <= 0; 
end 
else 
begin 
if(timer_1 == 5'd29) 
begin 
soft_reset_1 <= 1'b1; 
timer_1 <= 0; 
end 
else 
begin 
timer_1 <= timer_1 + 1'b1; 
soft_reset_1 <= 0; 
end 
end 
end 
 
// Logic for soft reset 2 
always@(posedge clock) 
begin 
if(!resetn) 
begin 
soft_reset_2 <= 0; 
timer_2 <= 0; 
end 
else if(~vld_out_2) 
begin 
soft_reset_2 <= 0; 
timer_2 <= 0; 
end 
else if(read_enb_2) 
begin 
soft_reset_2 <= 0; 
timer_2 <= 0; 
end 
else 
begin 
if(timer_2 == 5'd29) 
begin 
soft_reset_2 <= 1'b1; 
timer_2 <= 0; 
end 
else 
begin 
timer_2 <= timer_2 + 1'b1; 
soft_reset_2 <= 0; 
end 
end 
end 
endmodule 



//Simulation Code: 
module router_sync_tb(); 
reg 
clock_tb,resetn_tb,detect_add_tb,write_enb_reg_tb,read_enb_0_tb,read_enb_1_tb,read_enb_ 
2_tb,empty_0_tb,empty_1_tb,empty_2_tb,full_0_tb,full_1_tb,full_2_tb; 
reg [1:0] data_in_tb; 
wire 
fifo_full_tb,soft_reset_0_tb,soft_reset_1_tb,soft_reset_2_tb,vld_out_0_tb,vld_out_1_tb, 
vld_out_2_tb; 
wire [2:0] write_enb_tb; 
 
parameter T = 10, 
TIMEOUT = 30; 
 
router_sync DUT(clock_tb, 
resetn_tb, 
detect_add_tb, 
write_enb_reg_tb, 
read_enb_0_tb, 
read_enb_1_tb, 
11  
read_enb_2_tb, 
empty_0_tb, 
empty_1_tb, 
empty_2_tb, 
full_0_tb, 
full_1_tb, 
full_2_tb, 
data_in_tb, 
fifo_full_tb, 
soft_reset_0_tb, 
soft_reset_1_tb, 
soft_reset_2_tb, 
vld_out_0_tb, 
vld_out_1_tb, 
vld_out_2_tb, 
write_enb_tb); 
 
integer i,m; 
 
initial 
begin 
clock_tb = 1'b0; 
forever #(T/2) clock_tb = ~clock_tb; 
end 
 
task resetn_ip; 
begin 
@(negedge clock_tb); 
resetn_tb = 1'b0; 
@(negedge clock_tb); 
resetn_tb = 1'b1; 
end 
endtask 
 
task initialize; 
begin 
resetn_tb = 1'b1; 
detect_add_tb = 1'b0; 
write_enb_reg_tb = 1'b0; 
read_enb_0_tb = 1'b0; 
read_enb_1_tb = 1'b0; 
read_enb_2_tb = 1'b0; 
empty_0_tb = 1'b0; 
empty_1_tb = 1'b0; 
empty_2_tb = 1'b0; 
full_0_tb = 1'b0; 
full_1_tb = 1'b0; 
full_2_tb = 1'b0; 
end 
endtask 
 
task address_ip(input [1:0] addr_tb); 
begin 
@(negedge clock_tb); 
detect_add_tb = 1'b1; 
data_in_tb = addr_tb; 
@(negedge clock_tb); 
detect_add_tb = 1'b0; 
end 
endtask 
 
task write_enb_ip; 
begin 
@(negedge clock_tb); 
write_enb_reg_tb = 1'b1; 
@(negedge clock_tb); 
write_enb_reg_tb = 1'b0; 
 
end 
endtask 
 
task fifo_full_ip; 
begin 
full_0_tb = 1'b0; 
full_1_tb = 1'b1; 
full_2_tb = 1'b0; 
end 
endtask 
 
task empty_ip(input [3:0] j,k); 
begin 
empty_0_tb = j[0]; 
empty_1_tb = j[1]; 
empty_2_tb = j[2]; 
read_enb_0_tb = k[0]; 
read_enb_1_tb = k[1]; 
read_enb_2_tb = k[2]; 
end 
endtask 
 
initial 
begin 
initialize; 
resetn_ip; 
#10; 
m = 1; 
for(i=0;i<3;i=i+1) 
begin 
address_ip(i); 
write_enb_ip; 
fifo_full_ip; 
empty_ip(m,0); 
#10; 
empty_ip(0,0); 
#10; 
empty_ip(0,m); 
#10; 
empty_ip(0,0); 
m = m*2; 
end 
#700; 
$finish; 
end 
 
initial 
$monitor("Inputs : Detect Address = %b, Data_in = %b, Write Enable Reg = %b, 
Empty_0 = %b, Empty_1 = %b, Empty_2 = %b, Full_0 = %b, Full_1 = %b, Full_2 = %b, 
ReadEnable_0 = %b, ReadEnable_1 = %b, ReadEnable_2 = %b \nOutputs : Fifo Address = %b, 
Write Enable = %b,Fifo Full = %b, ValidOut_0 = %b, ValidOut_1 = %b, ValidOut_2 = %b, 
SoftReset_0 = %b, SoftReset_1 = %B, SoftReset_2 = %b", 
 
detect_add_tb,data_in_tb,write_enb_reg_tb,empty_0_tb,empty_1_tb,empty_2_tb,full_0_tb,fu 
ll_1_tb,full_2_tb,read_enb_0_tb,read_enb_1_tb,read_enb_2_tb,DUT.fifo_addr, 
write_enb_tb,fifo_full_tb,vld_out_0_tb,vld_out_1_tb,vld_out_2_tb,soft_reset_0_tb,soft_r 
eset_1_tb,soft_reset_2_tb); 
endmodule
