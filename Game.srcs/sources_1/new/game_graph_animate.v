`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2017 02:12:53 PM
// Design Name: 
// Module Name: game_graph_animate
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module game_graph_animate
   (
    input wire clk, reset,
    input wire video_on,
    input wire [9:0] pix_x, pix_y,
    input wire button,
    output reg [2:0] graph_rgb
   );

      // constant and signal declaration
      // x, y coordinates (0,0) to (639,479)
      localparam MAX_X = 640;
      localparam MAX_Y = 480;
      wire refr_tick;
      
      //--------------------------------------------
      // vertical stripe as a wall
      //--------------------------------------------
      // wall top, bottom boundary
      localparam WALL_Y_T = 0;
      localparam WALL_Y_B = 175;
      localparam WALL_X_L = 550;
      localparam WALL_X_R = 600;
      
      localparam WALL2_Y_T = 275;
      localparam WALL2_Y_B = 450;
      localparam WALL2_X_L = 550;
      localparam WALL2_X_R = 600;
      
     //--------------------------------------------
      // bottom horizontal bar
      //--------------------------------------------
      localparam GROUND_Y_T = 450;
      localparam GROUND_Y_B = 480;
      // bar top, bottom boundary
//      localparam BAR_X_L = 30;
//      localparam BAR_X_R = 38;
      // bar left, right boundary
//      wire [9:0] bar_y_t, bar_y_b;
//      localparam BAR_Y_SIZE = 72;
      // register to track right boundary  (y position is fixed)
//      reg [9:0] bar_y_reg, bar_y_next;
      // bar moving velocity when a button is pressed
//      localparam BAR_V = 4;
      
      //--------------------------------------------
      // square ball
      //--------------------------------------------
      localparam BALL_SIZE = 32;
      // ball left, right boundary
      wire [9:0] ball_x_l, ball_x_r;
      // ball top, bottom boundary
      wire [9:0] ball_y_t, ball_y_b;
      // reg to track left, top position
      reg [9:0] ball_x_reg, ball_y_reg;
      wire [9:0] ball_x_next, ball_y_next;
      // reg to track ball speed
      reg [9:0] x_delta_reg, x_delta_next;
      reg [9:0] y_delta_reg, y_delta_next;
      // ball velocity can be pos or neg)
      localparam BALL_V_P = 4;
      localparam BALL_V_N = -4;
      //--------------------------------------------
      // round ball
      //--------------------------------------------
      wire [4:0] rom_addr, rom_col;
      reg [31:0] rom_data;
      wire rom_bit;
      
      //--------------------------------------------
      // square cloud1
      //--------------------------------------------
      localparam CLOUD1_SIZE = 32;
      // ball left, right boundary
      wire [9:0] cloud1_x_l, cloud1_x_r;
      // ball top, bottom boundary
      wire [9:0] cloud1_y_t, cloud1_y_b;
      wire [4:0] cloud1_rom_addr, cloud1_rom_col;
      reg [31:0] cloud1_rom_data;
      wire cloud1_rom_bit;      
      
      //--------------------------------------------
      // square cloud2
      //--------------------------------------------
      localparam CLOUD2_SIZE = 32;
      // ball left, right boundary
      wire [9:0] cloud2_x_l, cloud2_x_r;
      // ball top, bottom boundary
      wire [9:0] cloud2_y_t, cloud2_y_b;
      wire [4:0] cloud2_rom_addr, cloud2_rom_col;
      reg [31:0] cloud2_rom_data;
      wire cloud2_rom_bit; 

      //--------------------------------------------
      // square cloud3
      //--------------------------------------------
      localparam CLOUD3_SIZE = 64;
      // ball left, right boundary
      wire [9:0] cloud3_x_l, cloud3_x_r;
      // ball top, bottom boundary
      wire [9:0] cloud3_y_t, cloud3_y_b;
      wire [5:0] cloud3_rom_addr, cloud3_rom_col;
      reg [63:0] cloud3_rom_data;
      wire cloud3_rom_bit; 
      
      //--------------------------------------------
      // object output signals
      //--------------------------------------------
      wire wall_on, wall2_on, bar_on, sq_ball_on, rd_ball_on;
      wire [2:0] wall_rgb, wall2_rgb, bar_rgb, ball_rgb;
      wire ground_on;
      wire [2:0] ground_rgb;
      wire sq_cloud1_on, rd_cloud1_on, sq_cloud2_on, rd_cloud2_on, sq_cloud3_on, rd_cloud3_on;
      wire [2:0] cloud1_rgb, cloud2_rgb, cloud3_rgb;
            
      integer mcounter = 0;
      integer counter_logic = 0;
      reg [3:0]dig1;
      reg [3:0]dig0;
      // body
      //--------------------------------------------
      // round ball image ROM
      //--------------------------------------------
      always @*
      case (rom_addr)
         5'h0: rom_data = 32'b00001111110000000000000000000000;
         5'h1: rom_data = 32'b00011111111000000000000000000000;
         5'h2: rom_data = 32'b00111111111100000000000000000000;
         5'h3: rom_data = 32'b01111111111110000000000000000000;
         5'h4: rom_data = 32'b11111111111111000000000000000000;
         5'h5: rom_data = 32'b11111111111111000000000000000000;
         5'h6: rom_data = 32'b11111111111111000000000000000001;
         5'h7: rom_data = 32'b11111111111111000011111100000111;
         5'h8: rom_data = 32'b11111111111111001111111111111111;
         5'h9: rom_data = 32'b11111111111111001111111111111111;
         5'ha: rom_data = 32'b01111111111110001111111111111111;
         5'hb: rom_data = 32'b00111111111111111111111111111111;
         5'hc: rom_data = 32'b00011111111111111111111111111111;
         5'hd: rom_data = 32'b00001111110111111111111111111111;
         5'he: rom_data = 32'b00000000000011111111111111111111;
         5'hf: rom_data = 32'b00000000000001111101111111111111;
         5'h10: rom_data = 32'b00001111111111111110001111111111;
         5'h11: rom_data = 32'b00001111111111111111000111111111;
         5'h12: rom_data = 32'b00001111111111111111100011111111;
         5'h13: rom_data = 32'b00000000000000000111110001111111;
         5'h14: rom_data = 32'b00000000000000000011111000000111;
         5'h15: rom_data = 32'b00000000000000000001111100000001;
         5'h16: rom_data = 32'b00000000000000000000111111100000;
         5'h17: rom_data = 32'b00000000000000000000011111110000;
         5'h18: rom_data = 32'b00000000000000000000001111111000;
         5'h19: rom_data = 32'b00000000000000000000001110011100;
         5'h1a: rom_data = 32'b00000000000000000000001110001110;
         5'h1b: rom_data = 32'b00000000000000000000000111000111;
         5'h1c: rom_data = 32'b00000000000000000000000011100011;
         5'h1d: rom_data = 32'b00000000000000000000000001110001;
         5'h1e: rom_data = 32'b00000000000000000000000000111000;
         5'h1f: rom_data = 32'b00000000000000000000000000011100;
      endcase
   
      //--------------------------------------------
      // round cloud image ROM
      //-------------------------------------------- 
      always @*
         case (cloud1_rom_addr)
            5'h0: cloud1_rom_data = 32'b00000000000000000000000000000000;
            5'h1: cloud1_rom_data = 32'b00000000000000000000000000000000;
            5'h2: cloud1_rom_data = 32'b00000000000000000000000000000000;
            5'h3: cloud1_rom_data = 32'b00000000000000000000000000000000;
            5'h4: cloud1_rom_data = 32'b00000000000111110000000000000000;
            5'h5: cloud1_rom_data = 32'b00000000011111111000000000000000;
            5'h6: cloud1_rom_data = 32'b00000000111111111100000000000000;
            5'h7: cloud1_rom_data = 32'b00000001111111111110000000000000;
            5'h8: cloud1_rom_data = 32'b00000011111111111110000000000000;
            5'h9: cloud1_rom_data = 32'b00000111111111111111000000000000;
            5'ha: cloud1_rom_data = 32'b00000111111111111111000000000000;
            5'hb: cloud1_rom_data = 32'b00000111111111111111100000000000;
            5'hc: cloud1_rom_data = 32'b00000111111111111111100000000000;
            5'hd: cloud1_rom_data = 32'b00000111111111111111000000000000;
            5'he: cloud1_rom_data = 32'b00000011111111111111111100000000;
            5'hf: cloud1_rom_data = 32'b00000011111111111111111111000000;
            5'h10: cloud1_rom_data = 32'b00111111111111111111111111100000;
            5'h11: cloud1_rom_data = 32'b01111111111111111111111111110000;
            5'h12: cloud1_rom_data = 32'b01111111111111111111111111110000;
            5'h13: cloud1_rom_data = 32'b01111111111111111111111111100000;
            5'h14: cloud1_rom_data = 32'b00111111111111111111111111111000;
            5'h15: cloud1_rom_data = 32'b01111111111111111111111111111110;
            5'h16: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h17: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h18: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h19: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h1a: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h1b: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h1c: cloud1_rom_data = 32'b11111111111111111111111111111111;
            5'h1d: cloud1_rom_data = 32'b01111111111111111111110111111110;
            5'h1e: cloud1_rom_data = 32'b00111111100111001111100011111100;
            5'h1f: cloud1_rom_data = 32'b00001100000000000011000001111000;
         endcase
   
      always @*
         case (cloud2_rom_addr)
            5'h0: cloud2_rom_data = 32'b00000000000000000000000000000000;
            5'h1: cloud2_rom_data = 32'b00000000000000000000000000000000;
            5'h2: cloud2_rom_data = 32'b00000000000000000000000000000000;
            5'h3: cloud2_rom_data = 32'b00000000000000000000000000000000;
            5'h4: cloud2_rom_data = 32'b00000000000111110000000000000000;
            5'h5: cloud2_rom_data = 32'b00000000011111111000000000000000;
            5'h6: cloud2_rom_data = 32'b00000000111111111100000000000000;
            5'h7: cloud2_rom_data = 32'b00000001111111111110000000000000;
            5'h8: cloud2_rom_data = 32'b00000011111111111110000000000000;
            5'h9: cloud2_rom_data = 32'b00000111111111111111000000000000;
            5'ha: cloud2_rom_data = 32'b00000111111111111111000000000000;
            5'hb: cloud2_rom_data = 32'b00000111111111111111100000000000;
            5'hc: cloud2_rom_data = 32'b00000111111111111111100000000000;
            5'hd: cloud2_rom_data = 32'b00000111111111111111000000000000;
            5'he: cloud2_rom_data = 32'b00000011111111111111111100000000;
            5'hf: cloud2_rom_data = 32'b00000011111111111111111111000000;
            5'h10: cloud2_rom_data = 32'b00111111111111111111111111100000;
            5'h11: cloud2_rom_data = 32'b01111111111111111111111111110000;
            5'h12: cloud2_rom_data = 32'b01111111111111111111111111110000;
            5'h13: cloud2_rom_data = 32'b01111111111111111111111111100000;
            5'h14: cloud2_rom_data = 32'b00111111111111111111111111111000;
            5'h15: cloud2_rom_data = 32'b01111111111111111111111111111110;
            5'h16: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h17: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h18: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h19: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h1a: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h1b: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h1c: cloud2_rom_data = 32'b11111111111111111111111111111111;
            5'h1d: cloud2_rom_data = 32'b01111111111111111111110111111110;
            5'h1e: cloud2_rom_data = 32'b00111111100111001111100011111100;
            5'h1f: cloud2_rom_data = 32'b00001100000000000011000001111000;
         endcase   
      
      always @*
         case (cloud3_rom_addr)
            6'h0: cloud3_rom_data = 64'b0000000000000000000000000000000000000001111111111000000000000000;
            6'h1: cloud3_rom_data = 64'b0000000000000000001111111000000000000011111111111100000000000000;
            6'h2: cloud3_rom_data = 64'b0000000000000001111111111111000000001111111111111111100000000000;
            6'h3: cloud3_rom_data = 64'b0000000000000011111111111111100000011111111111111111110000000000;
            6'h4: cloud3_rom_data = 64'b0000000000001111111111111111110000111111111111111111111000000000;
            6'h5: cloud3_rom_data = 64'b0000000000011111111111111111111000111111111111111111111110000000;
            6'h6: cloud3_rom_data = 64'b0000000000111111111111111111111000111111111111111111111111000000;
            6'h7: cloud3_rom_data = 64'b0000000001111111111111111111111100111111111111111111111111100000;
            6'h8: cloud3_rom_data = 64'b0000000011111111111111111111111101111111111111111111111111110000;
            6'h9: cloud3_rom_data = 64'b0000000111111111111111111111111101111111111111111111111111110000;
            6'ha: cloud3_rom_data = 64'b0000001111111111111111111111111111111111111111111111111111111000;
            6'hb: cloud3_rom_data = 64'b0000001111111111111111111111111111111111111111111111111111111100;
            6'hc: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111100;
            6'hd: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111100;
            6'he: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111110;
            6'hf: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111110;
            6'h10: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111110;
            6'h11: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111100;
            6'h12: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111111111111000;
            6'h13: cloud3_rom_data = 64'b0000001111111111111111111111111111111111111111111111111111111000;
            6'h14: cloud3_rom_data = 64'b0000001111111111111111111111111111111111111111111111111111110000;
            6'h15: cloud3_rom_data = 64'b0000001111111111111111111111111111111111111111111111111111110000;
            6'h16: cloud3_rom_data = 64'b0000000111111111111111111111111111111111111111111111111111000000;
            6'h17: cloud3_rom_data = 64'b0000000111111111111111111111111111111111111111111111111110000000;
            6'h18: cloud3_rom_data = 64'b0000000001111111111111111111111111111111111111111111111100000000;
            6'h19: cloud3_rom_data = 64'b0000000000111111111111111111111111111111111111111111111000000000;
            6'h1a: cloud3_rom_data = 64'b0000000000111111111111111111111111111111111111111111111000000000;
            6'h1b: cloud3_rom_data = 64'b0000000000111111111111111111111111111111111111111111100000000000;
            6'h1c: cloud3_rom_data = 64'b0000000011111111111111111111111111111111111111111111000000000000;
            6'h1d: cloud3_rom_data = 64'b0000011111111111111111111111111111111111111111111111100000000000;
            6'h1e: cloud3_rom_data = 64'b0000111111111111111111111111111111111111111111111111111100000000;
            6'h1f: cloud3_rom_data = 64'b0001111111111111111111111111111111111111111111111111111111000000;
            6'h20: cloud3_rom_data = 64'b0011111111111111111111111111111111111111111111111111111111110000;
            6'h21: cloud3_rom_data = 64'b0111111111111111111111111111111111111111111111111111111111111000;
            6'h22: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111000;
            6'h23: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111100;
            6'h24: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111110;
            6'h25: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111110;
            6'h26: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h27: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h28: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h29: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2a: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2b: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2c: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2d: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2e: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h2f: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h30: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h31: cloud3_rom_data = 64'b1111111111111111111111111111111111111111111111111111111111111111;
            6'h32: cloud3_rom_data = 64'b0111111111111111111111111111111111111111111111111111111111111111;
            6'h33: cloud3_rom_data = 64'b0011111111111111111111111111111111111111111111111111111111111111;
            6'h34: cloud3_rom_data = 64'b0011111111111111111111111111111111111111111111111111111111111110;
            6'h35: cloud3_rom_data = 64'b0001111111111111111111111111111111111111111111111111111111111110;
            6'h36: cloud3_rom_data = 64'b0000111111111111111111111111111111111111111111111111111111111100;
            6'h37: cloud3_rom_data = 64'b0000001111111111111111111111111111111110111111111111111111111100;
            6'h38: cloud3_rom_data = 64'b0000000000011111111111111111111111111110111111111111111111111000;
            6'h39: cloud3_rom_data = 64'b0000000000011111111111111111111111111100111111111111111111111000;
            6'h3a: cloud3_rom_data = 64'b0000000000011111111111111111111111110000001111111111111111110000;
            6'h3b: cloud3_rom_data = 64'b0000000000011111111111111111111111110000001111111111111111000000;
            6'h3c: cloud3_rom_data = 64'b0000000000001111111111111111111111000000000000111111111100000000;
            6'h3d: cloud3_rom_data = 64'b0000000000000111111111111111111110000000000000111111111000000000;
            6'h3e: cloud3_rom_data = 64'b0000000000000011111111111111110000000000000000000000000000000000;
            6'h3f: cloud3_rom_data = 64'b0000000000000000111111111111000000000000000000000000000000000000;
         endcase   
         
      // registers
      always @(posedge clk, posedge reset)
         if (reset)
            begin
//               bar_y_reg <= 0;
               ball_x_reg <= 30;
               ball_y_reg <= 0;
               x_delta_reg <= 10'h004;
               y_delta_reg <= 10'h004;
            end
         else
            begin
//               bar_y_reg <= bar_y_next;
               ball_x_reg <= ball_x_reg;
               ball_y_reg <= ball_y_next;
               x_delta_reg <= x_delta_reg;
               y_delta_reg <= y_delta_next;
            end
   
      // refr_tick: 1-clock tick asserted at start of v-sync
      //            i.e., when the screen is refreshed (60 Hz)
      assign refr_tick = (pix_y==481) && (pix_x==0);
   
      //--------------------------------------------
      // (wall) top horizontal strip
      //--------------------------------------------
      // pixel within wall
      assign wall_on = (WALL_Y_T<=pix_y) && (pix_y<=WALL_Y_B) && 
        (WALL_X_L <= pix_x) && (pix_x <= WALL_X_R);
      assign wall2_on = (WALL2_Y_T<=pix_y) && (pix_y<=WALL2_Y_B) && 
        (WALL2_X_L <= pix_x) && (pix_x <= WALL2_X_R); 
      // wall rgb output
      assign wall_rgb = 3'b100; // red
      assign wall2_rgb = 3'b100;// red
      
      //ground on
      assign ground_on = (GROUND_Y_T<=pix_y) && (pix_y<=GROUND_Y_B);
      //ground rgb output
      assign ground_rgb = 3'b010; // green
      //--------------------------------------------
      // bottom horizontal bar
      //--------------------------------------------
      // boundary
         
//      assign bar_y_t = bar_y_reg;
//      assign bar_y_b = bar_y_t + BAR_Y_SIZE - 1;
      // pixel within bar
//      assign bar_on = (BAR_X_L<=pix_x) && (pix_x<=BAR_X_R) &&
//                      (bar_y_t<=pix_y) && (pix_y<=bar_y_b);
      // bar rgb output
//      assign bar_rgb = 3'b010; // green
      // new bar x-position
      
      always @*
      begin
//         bar_y_next = bar_y_reg; // no move
           
         if (refr_tick)
         begin
//            if (button && (bar_y_b < (MAX_Y-1-BAR_V))) 
//               bar_y_next = bar_y_reg + BAR_V; // move right
            
//            else if (button && (bar_y_t > BAR_V))
//               bar_y_next = bar_y_reg - BAR_V; // move left
         end
      end
   
   //   --------------------------------------------
   //    square ball
   //   --------------------------------------------
   //    boundary
      assign ball_x_l = ball_x_reg;
      assign ball_y_t = ball_y_reg;
      assign ball_x_r = ball_x_l + BALL_SIZE - 1;
      assign ball_y_b = ball_y_t + BALL_SIZE - 1;
      // pixel within ball
      assign sq_ball_on =
               (ball_x_l<=pix_x) && (pix_x<=ball_x_r) &&
               (ball_y_t<=pix_y) && (pix_y<=ball_y_b);
      // map current pixel location to ROM addr/col
      assign rom_addr = pix_y[4:0] - ball_y_t[4:0];
      assign rom_col = pix_x[4:0] - ball_x_l[4:0];
      assign rom_bit = rom_data[rom_col];
      // pixel within ball
      assign rd_ball_on = sq_ball_on & rom_bit;
      // ball rgb output
      assign ball_rgb = 3'b000;   // black?
      // new ball position
      assign ball_x_next = (refr_tick) ? ball_x_reg+x_delta_reg :
                           ball_x_reg ;
      assign ball_y_next = (refr_tick) ? ball_y_reg+y_delta_reg :
                           ball_y_reg ;
      // new ball velocity
      
      always @*
      begin
         x_delta_next = x_delta_reg;
         y_delta_next = y_delta_reg;
         if (ball_x_l < 1) // reach left
            x_delta_next = BALL_V_P;
         else if (ball_x_r > (MAX_X-1)) // reach right
            x_delta_next = BALL_V_N;
         else if (ball_y_b > 450 ) // if you hit the ground
            y_delta_next = BALL_V_N;    // bounce back temporarily
         else if (ball_y_t < 1)  // if you hit the top
            y_delta_next = BALL_V_P;    // boune back temporarily
         
      end
   
      //--------------------------------------------   
      // clouds
      //--------------------------------------------   
      assign cloud1_x_l = 150;
      assign cloud1_y_t = 50;
      assign cloud1_x_r = cloud1_x_l + CLOUD1_SIZE - 1;
      assign cloud1_y_b = cloud1_y_t + CLOUD1_SIZE - 1;
      // pixel within cloud
      assign sq_cloud1_on =
               (cloud1_x_l<=pix_x) && (pix_x<=cloud1_x_r) &&
               (cloud1_y_t<=pix_y) && (pix_y<=cloud1_y_b);
      // map current pixel location to ROM addr/col
      assign cloud1_rom_addr = pix_y[4:0] - cloud1_y_t[4:0];
      assign cloud1_rom_col = pix_x[4:0] - cloud1_x_l[4:0];
      assign cloud1_rom_bit = cloud1_rom_data[cloud1_rom_col];
      // pixel within cloud
      assign rd_cloud1_on = sq_cloud1_on & cloud1_rom_bit;
      // cloud rgb output
      assign cloud1_rgb = 3'b111; //gray
      
      assign cloud2_x_l = 500;
      assign cloud2_y_t = 100;
      assign cloud2_x_r = cloud2_x_l + CLOUD2_SIZE - 1;
      assign cloud2_y_b = cloud2_y_t + CLOUD2_SIZE - 1;
      // pixel within cloud
      assign sq_cloud2_on =
               (cloud2_x_l<=pix_x) && (pix_x<=cloud2_x_r) &&
               (cloud2_y_t<=pix_y) && (pix_y<=cloud2_y_b);
      // map current pixel location to ROM addr/col
      assign cloud2_rom_addr = pix_y[4:0] - cloud2_y_t[4:0];
      assign cloud2_rom_col = pix_x[4:0] - cloud2_x_l[4:0];
      assign cloud2_rom_bit = cloud2_rom_data[cloud2_rom_col];
      // pixel within cloud
      assign rd_cloud2_on = sq_cloud2_on & cloud2_rom_bit;
      // cloud rgb output
      assign cloud2_rgb = 3'b111; //gray
      
      assign cloud3_x_l = 325;
      assign cloud3_y_t = 125;
      assign cloud3_x_r = cloud3_x_l + CLOUD3_SIZE - 1;
      assign cloud3_y_b = cloud3_y_t + CLOUD3_SIZE - 1;
      // pixel within cloud
      assign sq_cloud3_on =
               (cloud3_x_l<=pix_x) && (pix_x<=cloud3_x_r) &&
               (cloud3_y_t<=pix_y) && (pix_y<=cloud3_y_b);
      // map current pixel location to ROM addr/col
      assign cloud3_rom_addr = pix_y[5:0] - cloud3_y_t[5:0];
      assign cloud3_rom_col = pix_x[5:0] - cloud3_x_l[5:0];
      assign cloud3_rom_bit = cloud3_rom_data[cloud3_rom_col];
      // pixel within cloud
      assign rd_cloud3_on = sq_cloud3_on & cloud3_rom_bit;
      // cloud rgb output
      assign cloud3_rgb = 3'b111; //gray
      //--------------------------------------------
      // score counter
      //--------------------------------------------
      always@* 
      begin
         if ((ball_y_t == 460) && (counter_logic == 1) && refr_tick)// ball falls below bar
         begin
            mcounter = (mcounter + counter_logic);
            counter_logic = 0;
         end 
         else if ((ball_y_t == 200)&& (counter_logic == 0) && refr_tick)
            counter_logic = 1;
      end
      
      always@*
      case((mcounter%(10)))
         0: dig0 = 4'b0000; // 1s digit
         1: dig0 = 4'b0001; //
         2: dig0 = 4'b0010; //
         3: dig0 = 4'b0011; //
         4: dig0 = 4'b0100; //
         5: dig0 = 4'b0101; //
         6: dig0 = 4'b0110; //
         7: dig0 = 4'b0111; //
         8: dig0 = 4'b1000; //
         9: dig0 = 4'b1001; //
      endcase
      
      always@*
      case((mcounter/(10)))
         0: dig1 = 4'b0000; // 10s digit
         1: dig1 = 4'b0001; //
         2: dig1 = 4'b0010; //
         3: dig1 = 4'b0011; //
         4: dig1 = 4'b0100; //
         5: dig1 = 4'b0101; //
         6: dig1 = 4'b0110; //
         7: dig1 = 4'b0111; //
         8: dig1 = 4'b1000; //
         9: dig1 = 4'b1001; //
      endcase
      
      wire text_on, text_rgb;
      
      pong_text score_text(.clk(clk), .dig0(dig0[3:0]), .dig1(dig1[3:0]),
         .pix_x(pix_x), .pix_y(pix_y), .text_on(text_on), .text_rgb(text_rgb));
   
      //--------------------------------------------
      // rgb multiplexing circuit
      //--------------------------------------------
      always @*
         if (~video_on)
            graph_rgb = 3'b000; // blank
         else
            if (wall_on)
               graph_rgb = wall_rgb;
            else if (wall2_on)
               graph_rgb = wall2_rgb;
            else if (ground_on)
               graph_rgb = ground_rgb;
            else if (bar_on)
               graph_rgb = bar_rgb;
            else if (rd_ball_on)
               graph_rgb = ball_rgb;
            else if (rd_cloud1_on)
               graph_rgb = cloud1_rgb;
            else if (rd_cloud2_on)
               graph_rgb = cloud2_rgb;
            else if (rd_cloud3_on)
               graph_rgb = cloud3_rgb;
            else if (text_on)
               graph_rgb = text_rgb;
            else 
               graph_rgb = 3'b001; // blue background    
   endmodule
