module uart_top(
    input wire clk,
    input wire rst,
    input wire [7:0] tx_data,
    input wire tx_start,
    input wire rx,
    output wire [7:0] rx_data,
    output wire rx_ready,
    output wire tx
);

    // UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        //.baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .Tx(tx)
    );

    // UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
//        .baud_tick(baud_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
endmodule
