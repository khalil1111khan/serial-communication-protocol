//--------------This is when I press key it will show in teraterm too-----------------------
module uart_t(
    input wire clk,
    input wire rst,
    input wire rx,
    output wire [7:0] rx_data,
    output wire rx_ready,
    output wire tx,
    output reg [7:0] led_output
);

    wire tx_busy;
    reg tx_start_int;
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start_int),
        .tx_data(rx_data),
        .Tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
       // .baud_tick(baud_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_output <= 8'b0;
            tx_start_int <= 1'b0;
        end else begin
            if (rx_ready) begin
                led_output <= rx_data;
                if (!tx_busy) begin
                    tx_start_int <= 1'b1;
                end
            end else begin
                tx_start_int <= 1'b0;
            end
        end
    end
endmodule
