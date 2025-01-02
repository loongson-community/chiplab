 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */
`include "../soc_config.vh"

// 串口寄存器物理地址
`define OFS_FIFO                32'h1fe00002
`define OFS_LINE_CONTROL        32'h1fe00003
`define OFS_DIVISOR_MSB         32'h1fe00001
`define OFS_DIVISOR_LSB         32'h1fe00000
`define OFS_DATA_FORMAT         32'h1fe00003
`define OFS_MODEM_CONTROL       32'h1fe00004
`define OFS_LINE_STATUS         32'h1fe00005
`define UART_TX_REG             32'h1fe00000
`define UART_RX_REG             32'h1fe00000

`define UART_DATA_READY          32'h1
`define UART_TRANSMIT_FIFO_EMPTY 32'h20

// 第一个包的大小
`define UART_FIRST_PACKET_LEN   8'd131
// 其他包的大小(每次烧写的字节数)
`define UART_REMAIN_PACKET_LEN  8'd131

`define UART_RESP_ACK           32'h6
`define UART_RESP_NAK           32'h15

// 烧写起始地址
`define SRAM_START_ADDR          32'h1c000000


// 串口更新固件模块
module uart_debug(

    input wire clk,
    input wire rst_n,

    //AXI interface 
    //Read address channel
    output   [ 3:0] arid,
    output   [31:0] araddr,
    output   [ 3:0] arlen,
    output   [ 2:0] arsize,
    output   [ 1:0] arburst,
    output   [ 1:0] arlock,
    output   [ 3:0] arcache,
    output   [ 2:0] arprot,
    output          arvalid,
    input           arready,
    //Read data channel
    input    [ 3:0] rid,
    input    [31:0] rdata,
    input    [ 1:0] rresp,
    input           rlast,
    input           rvalid,
    output          rready,
    //Write address channel
    output   [ 3:0] awid,
    output   [31:0] awaddr,
    output   [ 3:0] awlen,
    output   [ 2:0] awsize,
    output   [ 1:0] awburst,
    output   [ 1:0] awlock,
    output   [ 3:0] awcache,
    output   [ 2:0] awprot,
    output          awvalid,
    input           awready,
    //Write data channel
    output   [ 3:0] wid,
    output   [31:0] wdata,
    output   [ 3:0] wstrb,
    output          wlast,
    output          wvalid,
    input           wready,
    //Write response channel
    input    [ 3:0] bid,
    input    [ 1:0] bresp,
    input           bvalid,
    output          bready,

    input           irq_rx,

    //输出处理器核复位信号
    output          core_rst

    );

    // 状态
    localparam  S_IDLE                      = 5'd0;
    localparam  S_INIT_FIFO                 = 5'd1;
    localparam  S_INIT_LINE_CONTROL         = 5'd2;
    localparam  S_INIT_DIVISOR_MSB          = 5'd3;
    localparam  S_INIT_DIVISOR_LSB          = 5'd4;
    localparam  S_INIT_DATA_FORMAT          = 5'd5;
    localparam  S_INIT_MODEM_CONTROL        = 5'd6;
    localparam  S_WAIT_BYTE                 = 5'd7;
    localparam  S_WAIT_BYTE2                = 5'd8;
    localparam  S_GET_BYTE                  = 5'd9;
    localparam  S_REC_FIRST_PACKET          = 5'd10;
    localparam  S_REC_REMAIN_PACKET         = 5'd11;
    localparam  S_SEND_ACK                  = 5'd12;
    localparam  S_SEND_ACK2                 = 5'd13;
    localparam  S_SEND_NAK                  = 5'd14;
    localparam  S_SEND_NAK2                 = 5'd15;
    localparam  S_CRC_START                 = 5'd16;
    localparam  S_CRC_CALC                  = 5'd17;
    localparam  S_CRC_END                   = 5'd18;
    localparam  S_WRITE_MEM                 = 5'd19;
    localparam  S_CORE_RESET                = 5'd20;
    localparam  S_CLOSE                     = 5'd21;

    reg[4:0]    state;
    reg[4:0]    next_state;

    // 存放串口接收到的数据
    reg[7:0]    rx_data[0:132];
    reg[7:0]    rec_bytes_index;
    reg[7:0]    need_to_rec_bytes;
    reg[15:0]   remain_packet_count;
    reg[31:0]   fw_file_size;
    reg[31:0]   write_mem_addr;
    reg[31:0]   write_mem_data;
    reg[7:0]    write_mem_byte_index0;
    reg         remain_packet_count_init;

    reg[15:0]   crc_result;
    reg[3:0]    crc_bit_index;
    reg[7:0]    crc_byte_index;

    reg         uart_debug_req;
    reg         uart_debug_we;
    reg[31:0]   uart_debug_addr;
    reg[31:0]   uart_debug_wdata;
    reg         uart_debug_stb;

    //uart debug response 信号
    wire        store_finish;
    wire        load_finish;

    reg [15:0]  wait_byte_count;

    reg [7:0]   command_rst_count;

/***********************BEGIN of FSM********************************/
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)
            state <= S_IDLE;
        else begin
            state <= next_state;
        end
    end

    //状态跳转控制
    always @(*) begin
        case(state)
            S_IDLE : begin
                next_state = S_INIT_FIFO;
            end
            S_INIT_FIFO : begin
                if(store_finish)
                    next_state = S_INIT_LINE_CONTROL;
                else
                    next_state = S_INIT_FIFO;
            end
            S_INIT_LINE_CONTROL : begin
                if(store_finish)
                    next_state = S_INIT_DIVISOR_MSB;
                else
                    next_state = S_INIT_LINE_CONTROL;
            end
            S_INIT_DIVISOR_MSB : begin
                if(store_finish)
                    next_state = S_INIT_DIVISOR_LSB;
                else
                    next_state = S_INIT_DIVISOR_MSB;
            end
            S_INIT_DIVISOR_LSB : begin
                if(store_finish)
                    next_state = S_INIT_DATA_FORMAT;
                else
                    next_state = S_INIT_DIVISOR_LSB;
            end
            S_INIT_DATA_FORMAT : begin
                if(store_finish)
                    next_state = S_INIT_MODEM_CONTROL;
                else
                    next_state = S_INIT_DATA_FORMAT;
            end
            S_INIT_MODEM_CONTROL : begin
                if(store_finish)
                    next_state = S_REC_FIRST_PACKET;
                else
                    next_state = S_INIT_MODEM_CONTROL;
            end
            S_REC_FIRST_PACKET : begin
                next_state = S_WAIT_BYTE;
            end
            S_REC_REMAIN_PACKET : begin
                next_state = S_WAIT_BYTE;
            end
            S_WAIT_BYTE : begin
                //if(irq_rx)
                if(load_finish & (((rdata>>8) & `UART_DATA_READY) == `UART_DATA_READY))
                    next_state = S_WAIT_BYTE2;
                else if(wait_byte_count == 16'hffff)
                    next_state = S_SEND_NAK;
                else
                    next_state = S_WAIT_BYTE;
            end
            S_WAIT_BYTE2 : begin
                if(load_finish)
                    next_state = S_GET_BYTE;
                else
                    next_state = S_WAIT_BYTE2;
            end
            S_GET_BYTE: begin
                if (rec_bytes_index == need_to_rec_bytes)
                    next_state = S_CRC_START;
                else
                    next_state = S_WAIT_BYTE;
            end
             S_CRC_START: begin
                next_state = S_CRC_CALC;
            end
            S_CRC_CALC: begin
                if ((crc_byte_index == need_to_rec_bytes - 2) && crc_bit_index == 4'h8)
                    next_state = S_CRC_END;
                else
                    next_state = S_CRC_CALC;
            end
            S_CRC_END: begin
                if (crc_result == {rx_data[need_to_rec_bytes - 1], rx_data[need_to_rec_bytes - 2]}) begin
                    if (need_to_rec_bytes == `UART_FIRST_PACKET_LEN && remain_packet_count == 16'h0) begin
                        next_state <= S_SEND_ACK;
                    end
                    else begin
                        next_state <= S_WRITE_MEM;
                    end
                end
                else begin
                    next_state <= S_SEND_NAK;
                end
            end
            S_WRITE_MEM: begin
                if (store_finish && (write_mem_byte_index0 == (need_to_rec_bytes -2)))
                    next_state = S_SEND_ACK;
                else
                    next_state = S_WRITE_MEM;
            end
            S_SEND_ACK: begin
                if(load_finish & (((rdata>>8) & `UART_TRANSMIT_FIFO_EMPTY) == `UART_TRANSMIT_FIFO_EMPTY))
                    next_state = S_SEND_ACK2;
                else begin
                    next_state = S_SEND_ACK;
                end
            end
            S_SEND_ACK2: begin
                if(store_finish) begin
                    if (remain_packet_count > 0) begin
                        next_state = S_REC_REMAIN_PACKET;
                    end
                    else begin
                        if(rx_data[0] == 8'hff && rx_data[128] == 8'hff)begin
                            next_state = S_CORE_RESET;
                        end
                        else if(rx_data[0] == 8'h11 && rx_data[128] == 8'h11)begin
                            next_state = S_CLOSE;
                        end
                        else begin
                            next_state = S_REC_FIRST_PACKET;
                        end
                    end
                end
                else
                    next_state = S_SEND_ACK2;
            end
            S_SEND_NAK: begin
                if(load_finish & (((rdata>>8) & `UART_TRANSMIT_FIFO_EMPTY) == `UART_TRANSMIT_FIFO_EMPTY))
                    next_state = S_SEND_NAK2;
                else begin
                    next_state = S_SEND_NAK;
                end
            end
            S_SEND_NAK2: begin
                if(store_finish) begin
                    if (remain_packet_count > 0) begin
                        next_state = S_REC_REMAIN_PACKET;
                    end
                    else begin
                        next_state = S_REC_FIRST_PACKET;
                    end
                end
                else
                    next_state = S_SEND_NAK2;
            end
            S_CORE_RESET: begin
                if(command_rst_count == 8'hff)
                    next_state = S_REC_FIRST_PACKET;
                else
                    next_state = S_CORE_RESET;
            end
            S_CLOSE: begin
                next_state = S_CLOSE;
            end
            default     :begin
                next_state = S_IDLE;
            end
        endcase
    end

    always @(*) begin
        case(state)
            S_IDLE : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_INIT_FIFO : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_FIFO;
                uart_debug_wdata = 32'h07;
                uart_debug_stb = 1'h1;
            end
            S_INIT_LINE_CONTROL : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_LINE_CONTROL;
                uart_debug_wdata = 32'h80;
                uart_debug_stb = 1'h1;
            end
            S_INIT_DIVISOR_MSB : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_DIVISOR_MSB;
                uart_debug_wdata = 32'h00;
                uart_debug_stb = 1'h1;
            end
            S_INIT_DIVISOR_LSB : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_DIVISOR_LSB;
                uart_debug_wdata = 32'h36;
                uart_debug_stb = 1'h1;
            end
            S_INIT_DATA_FORMAT : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_DATA_FORMAT;
                uart_debug_wdata = 32'h3;
                uart_debug_stb = 1'h1;
            end
            S_INIT_MODEM_CONTROL : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `OFS_MODEM_CONTROL;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h1;
            end
            S_REC_FIRST_PACKET : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_REC_REMAIN_PACKET : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_WAIT_BYTE : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h0;
                uart_debug_addr = `OFS_LINE_STATUS;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_WAIT_BYTE2 : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h0;
                uart_debug_addr = `UART_RX_REG;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_GET_BYTE : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_CRC_START : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_CRC_CALC : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_CRC_END : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_WRITE_MEM : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = write_mem_addr;
                uart_debug_wdata = write_mem_data;
                uart_debug_stb = 1'h0;
            end
            S_SEND_ACK : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h0;
                uart_debug_addr = `OFS_LINE_STATUS;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_SEND_ACK2 : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `UART_TX_REG;
                uart_debug_wdata = `UART_RESP_ACK;
                uart_debug_stb = 1'h1;
            end
            S_SEND_NAK : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h0;
                uart_debug_addr = `OFS_LINE_STATUS;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_SEND_NAK2 : begin
                uart_debug_req = 1'h1;
                uart_debug_we = 1'h1;
                uart_debug_addr = `UART_TX_REG;
                uart_debug_wdata = `UART_RESP_NAK;
                uart_debug_stb = 1'h1;
            end
            S_CORE_RESET : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            S_CLOSE : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
            default : begin
                uart_debug_req = 1'h0;
                uart_debug_we = 1'h0;
                uart_debug_addr = 32'h0;
                uart_debug_wdata = 32'h0;
                uart_debug_stb = 1'h0;
            end
        endcase
    end


    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            remain_packet_count <= 16'h0;
            remain_packet_count_init <= 1'h0;
        end
        else begin
            if(state == S_REC_FIRST_PACKET) begin
                remain_packet_count_init <= 1'h0;
            end
            else if((state == S_CRC_END) & (crc_result == {rx_data[need_to_rec_bytes - 1], rx_data[need_to_rec_bytes - 2]})) begin
                if(need_to_rec_bytes == `UART_FIRST_PACKET_LEN && remain_packet_count == 16'h0 && remain_packet_count_init == 1'h0)begin
                    if(rx_data[0] != 8'hff &&  rx_data[128] != 8'hff)
                        remain_packet_count <= {7'h0, fw_file_size[31:7]} + 1'h1;
                    else
                        remain_packet_count <= 16'h0;
                    remain_packet_count_init <= 1'h1;
                end
                else
                    remain_packet_count <= remain_packet_count -1'h1;
            end
            else begin
                remain_packet_count <= remain_packet_count;
            end
        end
    end
/***********************END of FSM********************************/

    //生成复位信号
    reg download_rst;//下载Bin文件导致的处理器复位信号
    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            download_rst <= 1'b0;
        end
        else begin
            if(state == S_REC_REMAIN_PACKET)
                download_rst <= 1'b0;
            else if(state == S_SEND_ACK2 && next_state == S_REC_FIRST_PACKET )
                download_rst <= 1'b1;
            else if(state == S_INIT_FIFO)
                download_rst <= 1'b1;
        end
    end

    reg command_rst;//上位机发出复位命令导致的复位信号

    //收到reset命令后,给出一段复位信号
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            command_rst_count <= 1'b0;
            command_rst <= 1'b0;
        end
        else begin
            if(state == S_CORE_RESET) begin
                command_rst_count <= command_rst_count + 1'b1;
                command_rst <= 1'b0;
            end
            else begin
                command_rst_count <= 1'b0;
                command_rst <= 1'b1;
            end
        end
    end

    assign core_rst = command_rst & download_rst;

    // 数据包的大小
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            need_to_rec_bytes <= 8'h0;
        end else begin
            case (state)
                S_REC_FIRST_PACKET: begin
                    need_to_rec_bytes <= `UART_FIRST_PACKET_LEN;
                end
                S_REC_REMAIN_PACKET: begin
                    need_to_rec_bytes <= `UART_REMAIN_PACKET_LEN;
                end
            endcase
        end
    end

    // 读接收到的串口数据
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rec_bytes_index <= 8'h0;
        end else begin
            case (state)
                S_WAIT_BYTE2: begin
                    if(load_finish)begin
                        rx_data[rec_bytes_index] <= rdata[7:0];
                        rec_bytes_index <= rec_bytes_index + 1'b1;
                    end
                end
                S_REC_FIRST_PACKET: begin
                    rec_bytes_index <= 8'h0;
                end
                S_REC_REMAIN_PACKET: begin
                    rec_bytes_index <= 8'h0;
                end
            endcase
        end
    end

    // 超时检测
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wait_byte_count <= 16'h0;
        end
        else begin
            if((state == S_WAIT_BYTE) && (rec_bytes_index > 8'h0) && load_finish)
                wait_byte_count <= wait_byte_count + 1'h1;
            else if(state == S_WAIT_BYTE2 && load_finish)
                wait_byte_count <= 16'h0;
            else
                wait_byte_count <= wait_byte_count;
        end
    end

    // 固件大小
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            fw_file_size <= 32'h0;
        end else begin
            case (state)
                S_CRC_START: begin
                    fw_file_size <= {rx_data[61], rx_data[62], rx_data[63], rx_data[64]};
                end
            endcase
        end
    end

    // 烧写固件
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            write_mem_addr <= 32'h0;
        end else begin
            case (state)
                S_REC_FIRST_PACKET: begin
                    write_mem_addr <= `SRAM_START_ADDR;
                end
                S_WRITE_MEM: begin
                    if(store_finish)
                        write_mem_addr <= write_mem_addr + 4;
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            write_mem_data <= 32'h0;
        end else begin
            case (state)
                S_REC_FIRST_PACKET: begin
                    write_mem_data <= 32'h0;
                end
                S_CRC_END: begin
                    write_mem_data <= {rx_data[4], rx_data[3], rx_data[2], rx_data[1]};
                end
                S_WRITE_MEM: begin
                    if(store_finish)
                        write_mem_data <= {rx_data[write_mem_byte_index0+8'h3], rx_data[write_mem_byte_index0+8'h2], rx_data[write_mem_byte_index0+8'h1], rx_data[write_mem_byte_index0]};
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            write_mem_byte_index0 <= 8'h0;
        end else begin
            case (state)
                S_REC_FIRST_PACKET: begin
                    write_mem_byte_index0 <= 8'h0;
                end
                S_CRC_END: begin
                    write_mem_byte_index0 <= 8'h5;
                end
                S_WRITE_MEM: begin
                    if(store_finish)
                        write_mem_byte_index0 <= write_mem_byte_index0 + 4;
                end
            endcase
        end
    end

    // CRC计算
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            crc_result <= 16'h0;
        end else begin
            case (state)
                S_CRC_START: begin
                    crc_result <= 16'hffff;
                end
                S_CRC_CALC: begin
                    if (crc_bit_index == 4'h0) begin
                        crc_result <= crc_result ^ rx_data[crc_byte_index];
                    end else begin
                        if (crc_bit_index < 4'h9) begin
                            if (crc_result[0] == 1'b1) begin
                                crc_result <= {1'b0, crc_result[15:1]} ^ 16'ha001;
                            end else begin
                                crc_result <= {1'b0, crc_result[15:1]};
                            end
                        end
                    end
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            crc_bit_index <= 4'h0;
        end else begin
            case (state)
                S_CRC_START: begin
                    crc_bit_index <= 4'h0;
                end
                S_CRC_CALC: begin
                    if (crc_bit_index < 4'h9) begin
                        crc_bit_index <= crc_bit_index + 1'b1;
                    end else begin
                        crc_bit_index <= 4'h0;
                    end
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            crc_byte_index <= 8'h0;
        end else begin
            case (state)
                S_CRC_START: begin
                    crc_byte_index <= 8'h1;
                end
                S_CRC_CALC: begin
                    if (crc_bit_index == 4'h0) begin
                        crc_byte_index <= crc_byte_index + 1'b1;
                    end
                end
            endcase
        end
    end

uart_debug_axi  u_uart_debug_axi (
    .clk                     ( clk                ),
    .rst_n                   ( rst_n              ),
    .uart_debug_req          ( uart_debug_req     ),
    .uart_debug_we           ( uart_debug_we      ),
    .uart_debug_addr         ( uart_debug_addr    ),
    .uart_debug_wdata        ( uart_debug_wdata   ),
    .uart_debug_stb          ( uart_debug_stb     ),
    .arready                 ( arready            ),
    .rid                     ( rid                ),
    .rdata                   ( rdata              ),
    .rresp                   ( rresp              ),
    .rlast                   ( rlast              ),
    .rvalid                  ( rvalid             ),
    .awready                 ( awready            ),
    .wready                  ( wready             ),
    .bid                     ( bid                ),
    .bresp                   ( bresp              ),
    .bvalid                  ( bvalid             ),

    .store_finish            ( store_finish       ),
    .load_finish             ( load_finish        ),
    .arid                    ( arid               ),
    .araddr                  ( araddr             ),
    .arlen                   ( arlen              ),
    .arsize                  ( arsize             ),
    .arburst                 ( arburst            ),
    .arlock                  ( arlock             ),
    .arcache                 ( arcache            ),
    .arprot                  ( arprot             ),
    .arvalid                 ( arvalid            ),
    .rready                  ( rready             ),
    .awid                    ( awid               ),
    .awaddr                  ( awaddr             ),
    .awlen                   ( awlen              ),
    .awsize                  ( awsize             ),
    .awburst                 ( awburst            ),
    .awlock                  ( awlock             ),
    .awcache                 ( awcache            ),
    .awprot                  ( awprot             ),
    .awvalid                 ( awvalid            ),
    .wid                     ( wid                ),
    .wdata                   ( wdata              ),
    .wstrb                   ( wstrb              ),
    .wlast                   ( wlast              ),
    .wvalid                  ( wvalid             ),
    .bready                  ( bready             )
);

endmodule
