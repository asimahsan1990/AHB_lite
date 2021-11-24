module  ahb_lite  #(parameter addr_width=32, data_width=32)(
    //interface
    input [addr_width-1:0] HAUSER, //interface address
    input [data_width-1:0] HWUSER, //interface data write
    input [2:0] HSUSER, // interface HSIZE
    input [2:0] HBUSER,//interface transfer mode
    input HWSUSER,//ready/write 
    input input_HB_valid, //user input transfer mode is vaild
    input input_data_valid,//data vaild to termintate the incr without any length

    output reg [data_width-1:0] HRUSER,//interface read port
    output reg read_valid, // user output is vaild
    output reg mode_change, 
    

    input clk,  //global signal
    input HRESETn,    //global signal
    
    input HREAdy, //tranfer reponse
    input HRESP, //tranfer reponse

    input [data_width-1:0] HRDATA, //data read

    output reg [addr_width-1:0] HADDR, //Address to slave
    output reg HWRITE,                 // read/write
    output reg [2:0] HSIZE,             //data size
    output reg [2:0] HBRUST,            // data mode 
    output reg [3:0] HPROT,             //data protection
    output reg [1:0] HTRANS,            //maste mode
    output reg HMASTLOCK,               //master lock
    output reg [data_width-1:0]  HWDATA         //data  write

);



parameter[1:0] IDLE =2'b00 ;
parameter[1:0] BUSY =2'b01 ;
parameter[1:0] NONSEQ =2'b10 ;
parameter[1:0] SEQ =2'b11 ;


parameter [2:0] SINGLE =3'b000 ;
parameter [2:0] INCR =3'b001 ;
parameter [2:0] WRAP4 =3'b010 ;
parameter [2:0] INCR4 =3'b011 ;
parameter [2:0] WRAP8 =3'b100 ;
parameter [2:0] INCR8 =3'b101 ;
parameter [2:0] WRAP16 =3'b110 ;
parameter [2:0] INCR16 =3'b111 ;

reg[data_width-1:0] pipeline_temp;
reg temp_HWSUSER;
reg [addr_width-1:0] tempcounter;
reg [addr_width-1:0] base_addr;

reg[2:0] temp_HBRUST;


reg[10:0] size_add;
reg[10:0] wrap_bits;
reg[10:0] counter;

reg[addr_width-1:0] warps_addr;
always @(posedge clk or negedge HRESETn) begin




if(!HRESETn)
begin
    $display("SYStem REset");
    HTRANS<=IDLE;
    HADDR<=0;
    HWDATA<=0;
    mode_change<=1;
    counter<=0;
    warps_addr=0;

end

if (HREAdy)
begin
pipeline_temp<=HWUSER;
HWDATA<=pipeline_temp;

HWRITE<=HWSUSER;
read_valid<=~HWRITE;


HRUSER<=HRDATA;



case(HTRANS) 
    IDLE:begin
	//$display("enter IDLE State");
        if(input_HB_valid)
        case (HBUSER)
            SINGLE:
                    begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=1;
                       // $display("Single IDLE");
                    end
            WRAP4:
                begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+1:0]+size_add;
                      //  $display("WARP4 IDLE ");
                        
                end
            WRAP8:
                begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+2:0]+size_add;
                        
                end
            WRAP16:
                begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+3:0]+size_add;
                        
                end    
            default:
                begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        
                end
            
            

        endcase
	else 
		begin
		HTRANS<=0;
		//$display("else IDLE State");
		end


    end
    
    BUSY:begin
            if ( input_HB_valid && mode_change==1)
                begin
                    case (HBUSER)
                                SINGLE:
                                        begin
                                            HADDR<=HAUSER;
                                            HBRUST<=HBUSER;
                                            HTRANS<=NONSEQ;
                                            mode_change<=1;
                                        //    $display("Single IDLE");
                                        end
                                WRAP4:
                                    begin
                                            HADDR<=HAUSER;
                                            HBRUST<=HBUSER;
                                            HTRANS<=SEQ;
                                            mode_change<=0;
                                            base_addr<=HAUSER;
                                            counter<=0;
                                            warps_addr<=HAUSER[2+1:0]+size_add;
                                            $display("WARP4 busy ");
                                            
                                    end
                                WRAP8:
                                    begin
                                            HADDR<=HAUSER;
                                            HBRUST<=HBUSER;
                                            HTRANS<=NONSEQ;
                                            mode_change<=0;
                                            base_addr<=HAUSER;
                                            counter<=0;
                                            warps_addr<=HAUSER[2+2:0]+size_add;
                                            
                                    end
                                WRAP16:
                                    begin
                                            HADDR<=HAUSER;
                                            HBRUST<=HBUSER;
                                            HTRANS<=NONSEQ;
                                            mode_change<=0;
                                            base_addr<=HAUSER;
                                            counter<=0;
                                            warps_addr<=HAUSER[2+3:0]+size_add;
                                            
                                    end    
                                default:
                                    begin
                                            HADDR<=HAUSER;
                                            HBRUST<=HBUSER;
                                            HTRANS<=NONSEQ;
                                            mode_change<=0;
                                            base_addr<=HAUSER;
                                            counter<=0;
                                            
                                    end
                                
                                

                endcase
                end
                else
                    HBRUST<=IDLE;


        
    end

    NONSEQ:begin
        case(HBUSER)
            SINGLE:
                begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HTRANS<=NONSEQ;
                        mode_change<=1;
                        HSIZE=HSUSER;
                    end

                else 
                   HTRANS<=IDLE;     

                end
            INCR:
                begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HSIZE=HSUSER;
                        HTRANS<=SEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        //$display("idel->non seq INCR %d",$time);
                    end
                else
                    begin
                        //$display("idel->non seq INCR");
                        HADDR<=base_addr+size_add;
                        base_addr<=base_addr+size_add;
                        HTRANS<=SEQ;
                    end



   
                end
            WRAP4:
            begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        //$display("inonseq->seq WARP4");
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HSIZE=HSUSER;
                        HTRANS<=SEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+1:0]+size_add;
                    end
                else
                    begin
                        //$display("idel->non seq WARP4");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+2],warps_addr[2+1:0]};
                        warps_addr<=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=SEQ;
                    end            
             
            end    
            WRAP8:
            begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        //$display("inonseq->seq WARP8");
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HSIZE=HSUSER;
                        HTRANS<=SEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+2:0]+size_add;
                    end
                else
                    begin
                        //$display("idel->non seq WARP8");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+3],warps_addr[2+2:0]};
                        warps_addr=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=SEQ;
                    end            
             
            end  
            WRAP16:
            begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        //$display("inonseq->seq WARP8");
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HSIZE=HSUSER;
                        HTRANS<=SEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;
                        warps_addr<=HAUSER[2+3:0]+size_add;
                    end
                else
                    begin
                        //$display("idel->non seq WARP8");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+4],warps_addr[2+3:0]};
                        warps_addr=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=SEQ;
                    end            
             
            end
        INCR4,INCR8,INCR16:
            begin
                if ( input_HB_valid && mode_change==1)
                    begin
                        //$display("nonseq->seq INCR4,INCR8,INCR16");
                        HADDR<=HAUSER;
                        HBRUST<=HBUSER;
                        HSIZE=HSUSER;
                        HTRANS<=SEQ;
                        mode_change<=0;
                        base_addr<=HAUSER;
                        counter<=0;

                    end
                else
                    begin
                        //$display("idel->non seq WARP8");
                        counter<=counter+1;
                        HADDR<=base_addr+size_add;
                        base_addr<=base_addr+size_add;
                        HTRANS<=SEQ;
                    end            
             
            end

        

        endcase
    end

    SEQ:begin
            case (HBRUST)
                INCR: begin
                    //$display("Seq INCR %d",$time);
                    HADDR<=base_addr+size_add;
                    base_addr<=base_addr+size_add;
                    HTRANS<=SEQ;
                    if(input_data_valid==1)
			            begin
    	                    HTRANS<=BUSY;
                            mode_change<=1;
				            ///$display("Seq INCR termination");	
			            end
                end
                WRAP4:
            
                    begin
                        //$display("seq-> WARP4");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+2],warps_addr[2+1:0]};
                        warps_addr=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=(counter<2)?SEQ:IDLE;
                    end
                WRAP8:
                    begin
                        //$display("seq-> WARP8");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+3],warps_addr[2+1:0]};
                        warps_addr=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=(counter<6)?SEQ:IDLE;
                    end
                WRAP16:
                    begin
                        //$display("seq-> WARP16");
                        counter<=counter+1;
                        HADDR<={base_addr[addr_width-1:2+4],warps_addr[2+1:0]};
                        warps_addr=warps_addr+size_add;
                        base_addr<=base_addr;
                        HTRANS<=(counter<14)?SEQ:IDLE;
                    end           
                INCR4:
                    begin
                        //$display("seq-> incr4");
                        counter<=counter+1;
                        HADDR<=base_addr+size_add;
                        base_addr<=base_addr+size_add;
                        HTRANS<=(counter<3)?SEQ:IDLE;
                    end
                INCR8:
                    begin
                        //$display("seq-> incr4");
                        counter<=counter+1;
                        HADDR<=base_addr+size_add;
                        base_addr<=base_addr+size_add;
                        HTRANS<=(counter<7)?SEQ:IDLE;
                    end
                INCR16:
                    begin
                        //$display("seq-> incr4");
                        counter<=counter+1;
                        HADDR<=base_addr+size_add;
                        base_addr<=base_addr+size_add;
                        HTRANS<=(counter<15)?SEQ:IDLE;
                    end  

                


                default:
                    HBRUST<=IDLE; 
            endcase        
        
        
    end
    endcase
end

end


always @(HSUSER) begin
	case(HSUSER)
	3'b000:size_add<=1;
	3'b001:size_add<=2;
    	3'b010:size_add<=4;
    	3'b011:size_add<=8;
    	3'b100:size_add<=16;
    	3'b101:size_add<=32;
    	3'b110:size_add<=64;
    	3'b111:size_add<=128;
	endcase
end
always @(*) begin
	case(HSUSER)
	    3'b000:wrap_bits<=0;
	    3'b001:wrap_bits<=1;
    	3'b010:wrap_bits<=2;
    	3'b011:wrap_bits<=3;
    	3'b100:wrap_bits<=4;
    	3'b101:wrap_bits<=5;
    	3'b110:wrap_bits<=6;
    	3'b111:wrap_bits<=7;
	endcase    

    
end





endmodule