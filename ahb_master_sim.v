module ahb_master_sim;
reg           HCLK;
reg           HRESETn;
reg           HSEL;
reg   [31:0]  HADDR;
reg           HWRITE;
reg   [2:0]   HSIZE;
reg   [2:0]   HBURST;
reg   [3:0]   HPROT;
reg   [1:0]   HTRANS;
reg           HMASTLOCK;
reg           HREADY;
reg   [31:0]  HWDATA;
wire          HREADYOUT;
wire          HRESP;
wire [31:0]   HRDATA;


ahb_slave uut 	(.*);

//CLOCK DEF
initial 
begin HCLK=0; 
forever #5 HCLK=~HCLK; 
end


initial
begin
HRESETn=1;
HBURST=3'b010;
#5 HRESETn=0;
#5 HRESETn=1;
HSEL=1;
HREADY=1;
HWRITE=1;
HTRANS = 2'b01;
HADDR=32'h0000_0001;
HWDATA=32'h0000_0101;
HSIZE=3'b000;
#18
HSEL=1;
HREADY=1;
HWRITE=1;
HADDR=32'h0000_0005;
HWDATA=32'h0000_0011;
HSIZE=3'b000;



#20
HSEL=1;
HREADY=1;
HWRITE=0;
HADDR=32'h0000_0005;

HSIZE=3'b000;
#3
HTRANS = 2'b00;
#7
HSEL=1;
HREADY=1;
HWRITE=0;
HADDR=32'h0000_0001;
HSIZE=3'b000;
#16
HTRANS = 2'b01;


#20
HSEL=1;
HREADY=1;
HWRITE=1;
HTRANS = 2'b01;
HADDR=32'h0000_0001;
HWDATA=32'h0000_8101;
HSIZE=3'b000;
#18
HSEL=1;
HREADY=1;
HWRITE=1;
HADDR=32'h0000_0005;
HWDATA=32'h0000_5011;
HSIZE=3'b000;



#20
HSEL=1;
HREADY=1;
HWRITE=0;
HADDR=32'h0000_0005;

HSIZE=3'b000;
#3
HTRANS = 2'b00;
#7
HSEL=1;
HREADY=1;
HWRITE=0;
HADDR=32'h0000_0001;
HSIZE=3'b000;
#16
HTRANS = 2'b01;
end


initial
begin
#400
$finish;
end

endmodule