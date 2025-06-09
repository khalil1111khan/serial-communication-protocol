module uart_rx(
    input wire clk,                  
    input wire rst,                
    input wire rx,                      // UART receive line (serial data input)
    output reg [7:0] rx_data,           // received data (parallel output)
    output reg rx_ready                 // flag indicating when data is ready
);
    
    parameter CLK_FREQ = 100000000;
    parameter BAUD_RATE = 9600; 
    
    // baud period calculation
    localparam integer BAUD_TICK_COUNT = CLK_FREQ / BAUD_RATE;

    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b010;
    localparam STOP   = 3'b011;

    reg [2:0] state;                  
    reg [3:0] bit_index;         
    reg [7:0] shift_reg;               
    reg [15:0] baud_counter;        

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rx_data <= 8'b0;
            bit_index <= 4'b0;
            rx_ready <= 1'b0;
            shift_reg <= 8'b0;
            baud_counter <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    rx_ready <= 1'b0;        // clear ready flag
                    baud_counter <= 16'd0;   // reset baud counter
                    if (rx == 1'b0) begin    // detect start bit (falling edge)
                        state <= START;
                    end
                end

                START: begin
                    if (rx == 1'b0) begin // detect start bit (low level)
                        state <= DATA;     
                        bit_index <= 4'b0;  
                        baud_counter <= 16'd0; 
                    end else begin
                        state <= IDLE;     
                    end
                end
 

                DATA: begin
                    if (baud_counter == BAUD_TICK_COUNT / 2) begin // midpoint sampling
                        shift_reg <= {rx, shift_reg[7:1]}; // shift in the received bit
                    end    
                    if (baud_counter == BAUD_TICK_COUNT - 1) begin
                        baud_counter <= 0;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                STOP: begin
                    if (baud_counter == BAUD_TICK_COUNT - 1) begin
                        baud_counter <= 16'd0;
                        if (rx == 1'b1) begin 
                            rx_data <= shift_reg; 
                            rx_ready <= 1'b1;   
                        end
                        state <= IDLE;         
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
