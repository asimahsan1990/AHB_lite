module ahb_slave (
    //GLOBAL INPUTS
    input           HCLK,
    input           HRESETn,
    //MASTER INPUTS
    input           HSEL,
    input   [31:0]  HADDR,
    input           HWRITE,
    input   [2:0]   HSIZE,
    input   [2:0]   HBURST,
    input   [3:0]   HPROT,
    input   [1:0]   HTRANS,
    input           HMASTLOCK,
    input           HREADY,
    input   [31:0]  HWDATA,
    //OUTPUTS TO MASTER
    output reg          HREADYOUT,
    output reg          HRESP,
    output reg [31:0]   HRDATA
);
//Memory as a Slave
reg [7:0] mem [(2**6)-1:0];
reg [31:0] ADDR;
//State Machine
parameter IDLE      = 2'b00;
parameter READY     = 2'b01;
parameter write     = 2'b10;
parameter read      = 2'b11;
reg [1:0] current_state;
reg [1:0] next_state;
always @ (posedge HCLK , negedge HRESETn)           //State Transition At Edge of Clock
begin
    if(!HRESETn)                                    //Active Low Reset
    begin
        current_state <= IDLE;
    end
    else                                            //If reset is High, transition the state to next state
    begin
        current_state <= next_state;
    end
end
always @ (*)
begin
    case (current_state)
        IDLE:
            begin
                if (HSEL) begin
                    next_state = READY;
                end
                else begin
                    next_state = IDLE;
                end
            end
        READY:
            begin
                if (HWRITE && HREADY) begin
                    next_state = write;
                end
                else if (!HWRITE && HREADY) begin
                    next_state = read;
                end
                else begin
                    next_state = READY;
                end
            end
        write: begin
            next_state = (!HWRITE && HREADY)?  read: HBURST? write:  HSEL? READY : IDLE;
        end
        read: begin
            next_state = (HWRITE && HREADY)? write:
                        HBURST? read:
                        HSEL? READY:
                        IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
always @ (posedge HCLK, negedge HRESETn)
begin
    if (!HRESETn) begin
        HREADYOUT   <= 1;
        HRESP       <= 0;
        HRDATA      <= 'b0;
    end
    else
    begin
        case (next_state)
            IDLE: begin
                HREADYOUT   <= 1;
                HRESP       <= 0;
                HRDATA      <= HRDATA;
            end
            READY: begin
                HREADYOUT   <= 1;
                HRESP       <= 0;
                HRDATA      <= HRDATA;
            end
            write: begin
                HREADYOUT   <= 1;
                HRESP       <= 0;
                ADDR          = (|HTRANS) ? HADDR : ADDR;
                mem [ADDR] = HWDATA[7:0];
                mem [ADDR + 1] = HWDATA[15:8];
                mem [ADDR + 2] = HWDATA[23:16];
                mem [ADDR + 3] = HWDATA[31:24];
            end
            read: begin
                HREADYOUT   <= 1;
                HRESP       <= 0;
                ADDR         = (|HTRANS) ? HADDR : ADDR;
                HRDATA [7:0]     <= mem [ADDR];
                HRDATA [15:8]     <= mem [ADDR + 1];
                HRDATA [23:16]     <= mem [ADDR + 2];
                HRDATA [31:24]     <= mem [ADDR + 3];
            end
        default: begin
            HREADYOUT   <= 0;
            HRESP       <= 0;
            HRDATA      <= HRDATA;
        end
        endcase
    end
end
endmodule