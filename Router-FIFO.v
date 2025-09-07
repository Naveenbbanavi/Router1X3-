//Design Code: 
module router_fifo(input clock, 
resetn, 
write_enb, 
soft_reset, 
read_enb, 
lfd_state, 
input [7:0] data_in, 
output empty,full, 
output reg [7:0] data_out); 
 
reg [8:0] mem [0:15]; 
reg [4:0] wr_ptr,rd_ptr; 
reg [6:0] fifo_counter; 
reg lfd_tmp; 
integer i; 
 
// Logic for lfd_state 
always@(posedge clock) 
begin 
if(!resetn) 
lfd_tmp <= 0; 
else 
lfd_tmp <= lfd_state; 
end 
 
// Logic for read and write pointer 
always@(posedge clock) 
begin 
if(!resetn) 
begin 
wr_ptr <= 0; 
rd_ptr <= 0; 
end 
else if(soft_reset) 
begin 
wr_ptr <= 0; 
rd_ptr <= 0; 
end 
else 
begin 
if(!full && write_enb) 
wr_ptr <= wr_ptr + 1'b1; 
if(!empty && read_enb) 
rd_ptr <= rd_ptr + 1'b1; 
end 
end 
 
// Logic for FIFO counter 
always@(posedge clock) 
begin 
if(!resetn) 
fifo_counter <= 0; 
else if(soft_reset) 
fifo_counter <= 0; 
else if(read_enb && !empty) 
begin 
if(mem[rd_ptr[3:0]][8] == 1'b1) 
fifo_counter <= mem[rd_ptr[3:0]][7:2] + 1'b1; 
else if(fifo_counter) 
fifo_counter <= fifo_counter - 1'b1; 
end 
end 
// Logic for read operation 
always@(posedge clock) 
begin 
if(!resetn) 
data_out <= 0; 
else if(soft_reset) 
data_out <= 8'bz; 
else if(!fifo_counter && empty) 
data_out <= 8'bz; 
else if(read_enb && !empty) 
data_out <= mem[rd_ptr[3:0]][7:0]; 
end 
 
// Logic for write operation 
always@(posedge clock) 
begin 
if(!resetn) 
for(i=0;i<16;i=i+1) 
mem[i] <= 0; 
else if(soft_reset) 
for(i=0;i<16;i=i+1) 
mem[i] <= 0; 
else if(write_enb && !full) 
mem[wr_ptr[3:0]] <= {lfd_tmp,data_in}; 
end 
 
// Logic for empty and full 
assign empty = (wr_ptr==rd_ptr)?1'b1:1'b0; 
assign full = (wr_ptr=={~rd_ptr[4],rd_ptr[3:0]})?1'b1:1'b0; 
endmodule 





//Simulation Code
module router_fifo_tb(); 
parameter T = 10, 
TIMEOUT = 30, 
PAYLOAD_LENGTH = 6'd14, 
ADDRESS = 2'd1; 
reg clock_tb,resetn_tb,write_enb_tb,soft_reset_tb,read_enb_tb,lfd_state_tb; 
reg [7:0] data_in_tb; 
wire full_tb, empty_tb; 
wire [7:0] data_out_tb; 
 
integer i,j,k; 
reg [7:0] header,payload,parity; 
 
router_fifo 
DUT(clock_tb,resetn_tb,write_enb_tb,soft_reset_tb,read_enb_tb,lfd_state_tb,data_in_tb,e 
mpty_tb,full_tb,data_out_tb); 
 
initial 
begin 
clock_tb = 1'b0; 
forever #(T/2) clock_tb = ~clock_tb; 
end 
 
task initialize; 
begin 
resetn_tb = 1; 
soft_reset_tb = 0; 
write_enb_tb = 0; 
read_enb_tb = 0; 
end 
endtask 
 
task resetn_ip; 
begin 
@(negedge clock_tb); 
resetn_tb = 1'b0; 
@(negedge clock_tb); 
resetn_tb = 1'b1; 
end 
endtask 
 
task soft_reset_ip; 
begin 
@(negedge clock_tb); 
soft_reset_tb = 1'b1; 
#TIMEOUT; 
@(negedge clock_tb); 
soft_reset_tb = 1'b0; 
end 
endtask 
 
task write; 
begin 
lfd_state_tb = 1'b1; 
@(negedge clock_tb); 
header = {PAYLOAD_LENGTH,ADDRESS}; 
data_in_tb = header; 
@(negedge clock_tb); 
lfd_state_tb = 1'b0; 
write_enb_tb = 1'b1; 
parity = 0; 
for(i=0;i<PAYLOAD_LENGTH;i=i+1) 
begin 
@(negedge clock_tb); 
payload = {$random}%256; 
parity = payload ^ parity; 
data_in_tb = payload; 
end 
@(negedge clock_tb); 
data_in_tb = parity; 
end 
endtask 
 
task read(input j,k); 
begin 
write_enb_tb = j; 
read_enb_tb = k; 
end 
endtask 
 
initial 
begin 
initialize; 
resetn_ip; 
#20; 
write; 
#20; 
for(i=0;i<PAYLOAD_LENGTH + 2;i=i+1) 
begin 
read(1'b0,1'b1); 
#15; 
end 
read(1'b0,1'b0); 
#20; 
resetn_ip; 
#10; 
write; 
#30; 
soft_reset_ip; 
#30;  
$finish; 
end 
 
initial 
$monitor("Data Input = %b, Data_output = %b, Reset = %b, Soft Reset = %b, Write 
Enable = %b, Read Enable = %b,Lfd State = %b, FIFO Counter = %b, Empty = %b, Full = 
%b", 
data_in_tb,data_out_tb,resetn_tb,soft_reset_tb,write_enb_tb,read_enb_tb,lfd_state_tb,DU 
T.fifo_counter,empty_tb,full_tb); 
endmodule 



