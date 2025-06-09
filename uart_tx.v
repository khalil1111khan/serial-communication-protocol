module uart_tx(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg Tx,
    output reg tx_busy    
);

    parameter clk_frq = 100000000;    // 100 MHz clock frequency
    parameter baud_rate = 9600;   
    parameter baud_tik = clk_frq / baud_rate;

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    reg [2:0] state;              
    reg [15:0] baud_count;       
    reg [3:0] bit_index;          
    reg [7:0] shift_reg;       

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            baud_count <= 16'b0;
            bit_index <= 4'b0;
            shift_reg <= 8'b0;
            Tx <= 1'b1;         
            tx_busy <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    Tx <= 1'b1;     // keep line high in IDLE
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= tx_data;   // load data to transmit
                        baud_count <= 16'b0;    // reset baud counter
                        bit_index <= 4'b0;
                        tx_busy <= 1'b1;
                        state <= START;         
                    end
                end

                START: begin
                    Tx <= 1'b0;     // send start bit (0)
                    if (baud_count < baud_tik - 1) begin
                        baud_count <= baud_count + 1;
                    end else begin
                        baud_count <= 0;
                        state <= DATA;          
                    end
                end

                DATA: begin
                    Tx <= shift_reg[0];         // send lsb of shift register
                    if (baud_count < baud_tik - 1) begin
                        baud_count <= baud_count + 1;
                    end else begin
                        baud_count <= 0;
                        shift_reg <= shift_reg >> 1;  // shift data right
                        bit_index <= bit_index + 1;
                        if (bit_index == 7) begin
                            state <= STOP;       // move to stop state after 8 bits
                        end
                    end
                end

                STOP: begin
                    Tx <= 1'b1;                 // send stop bit (1)
                    if (baud_count < baud_tik - 1) begin
                        baud_count <= baud_count + 1;
                    end else begin
                        baud_count <= 0;
                        state <= IDLE;          // return to idle state
                        tx_busy <= 1'b0;        // transmission complete
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
