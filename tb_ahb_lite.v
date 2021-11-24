module tb();
parameter addr_width=32, data_width=32;
    //interface
    reg [addr_width-1:0] HAUSER; //interface address
    reg [data_width-1:0] HWUSER; //interface data write
    reg [2:0] HSUSER; // interface HSIZE
    reg [3:0] HBUSER;//interface transfer mode
    reg HWSUSER;//ready/write 
    reg input_HB_valid; //user input transfer mode is vaild
    reg input_data_valid;//data vaild

    wire [data_width-1:0] HRUSER;//interface read port
    wire read_valid; // user output is vaild
    wire mode_change;
    

    reg clk;  //global signal
    reg HRESETn;    //global signal
    
    wire HREAdy; //tranfer reponse
    reg HRESP; //tranfer reponse

    wire [data_width-1:0] HRDATA; //data read

    wire [addr_width-1:0] HADDR; //Address to slave
    wire HWRITE;                 // read/write
    wire [2:0] HSIZE;             //data size
    wire [2:0] HBRUST;            // data mode 
    //wire [3:0] HPROT;             //data protection
    wire [1:0] HTRANS;            //maste mode
    //wire HMASTLOCK;               //master lock
    wire [data_width-1:0]  HWDATA;         //data  write

    integer i;

    ahb_lite #(.addr_width(addr_width),
            .data_width(data_width))

            ahb_lite_1  (
        
        .HAUSER(HAUSER),
        .HWUSER(HWUSER),
        .HSUSER(HSUSER),
        .HBUSER(HBUSER),
        .HWSUSER(HWSUSER),
        .input_HB_valid(input_HB_valid),
        .input_data_valid(input_data_valid),
        .read_valid(read_valid),


        .clk(clk),
        .HRESETn(HRESETn),

        .HREAdy(HREAdy),
        .HRESP(HRESP),
        .HRDATA(HRDATA),

	
        .HADDR(HADDR),
        .HWRITE(HWRITE),
    	.HSIZE(HSIZE),
        .HBRUST(HBRUST),
	.HTRANS(HTRANS),
        .HWDATA(HWDATA)



    );

ahb_slave ahb_slave_1(
    //GLOBAL INPUTS
    .HCLK(clk),
    .HRESETn(HRESETn),
    //MASTER INPUTS
    .HSEL(1),
    .HADDR(HADDR),
    .HWRITE(HWRITE),
    .HBURST(HBRUST),
    .HTRANS(HTRANS),
    .HREADY(1'b1),
    .HWDATA(HWDATA),
    .HRDATA(HRDATA),
    .HSIZE(3'b010),
    .HREADYOUT(HREAdy)
);


    task expect_Addr;
    input [addr_width-1:0] exp_out;
    if (HADDR != exp_out) begin
      $display("TEST FAILED,at time %d expected=%d,HADDR=%d", $time,exp_out,HADDR);
    end
    else begin
      $display("TEST passed,%d HADDR=%d",$time,exp_out);
    end
  endtask

task expect_data;
    input [addr_width-1:0] exp_data;
    if (HWDATA != exp_data) begin
      $display("TEST FAILED,at time %d expected=%d,HWDATA=%d", $time,exp_data,HWDATA);
    end
    else begin
      $display("TEST passed,%d HWDATA=%d",$time,exp_data);
    end
  endtask 

  initial
  begin
        $display("Single burst");
        #15;
        @(negedge clk) expect_Addr (0);
        @(negedge clk) expect_Addr (4);
        expect_data(16);
        @(negedge clk) expect_Addr (8);
        expect_data(32);
        @(negedge clk) expect_Addr (12);
        expect_data(64);
        @(negedge clk) expect_Addr (16);
        expect_data(128);
        $display("undefined length burst");
        @(negedge clk) expect_Addr (20);
        expect_data(256);
        @(negedge clk) expect_Addr (24);
        expect_data(0);
        @(negedge clk) expect_Addr (28);
        expect_data(1);
        @(negedge clk) expect_Addr (32);
        expect_data(2);
        @(negedge clk) expect_Addr (36);
        expect_data(3);
        @(negedge clk) expect_Addr (40);
        expect_data(4);
        @(negedge clk) expect_Addr (44);
        expect_data(5);
        @(negedge clk) expect_Addr (48);
        expect_data(6);
        @(negedge clk) expect_Addr (52);
        expect_data(7);
        @(negedge clk) expect_Addr (56);
        expect_data(8);
        @(negedge clk) expect_Addr (60);
        expect_data(9);
        $display("WARP4");
        @(negedge clk) expect_Addr (20);
        expect_data(0);
        @(negedge clk) expect_Addr (24);
        expect_data(10);
        @(negedge clk) expect_Addr (28);
        expect_data(20);
        @(negedge clk) expect_Addr (16);
        expect_data(30);
        @(negedge clk)   expect_data(40);
        #5;
        $finish;


            
        
  end

    initial begin
    clk=0;
	input_HB_valid=1;
	HAUSER=0;
	HWUSER=0;
	HBUSER=0;
	HSUSER=2;
	HWSUSER=1;
    HRESETn=0;
    input_data_valid=0;
    #3;
    HRESETn=1;

    #7
	HAUSER=0;
	HWUSER=16;
    #10;
	HAUSER=4;
	HWUSER=32;
	#10;
	HAUSER=8;
	HWUSER=64;
    #10;
	HAUSER=12;
	HWUSER=128;
    #10;
	HAUSER=16;
	HWUSER=256;
    #10;
    HBUSER=1;
    HAUSER=20;
    HWUSER=0;
    input_data_valid=0;
    //input_HB_valid=0;
    for(i=1;i<10;i=i+1)
    begin
        #10;
        HBUSER=1;
        HAUSER=20;
        HWUSER=i;
    end

    input_HB_valid=1;
    #10;
    HWUSER=00;
    input_data_valid=1;
    //HWUSER=10;
    #10;
    HBUSER=2;
    HWUSER=10;

    #10;
    input_data_valid=0;
    input_HB_valid=1;
    HWUSER=20;
    #10;
    HWUSER=30;
    #10;
    HWUSER=40;
    #30
    input_data_valid=0;
    
   end



    always #5 clk=~clk;


endmodule
