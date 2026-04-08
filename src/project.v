/*
 * Two-card poker hand comparator for Tiny Tapeout.
 * Each player has two cards (rank only). Pair beats any non-pair; else high card then kicker.
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tt_um_poker_game (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // high when this design is selected
    input  wire       clk,      // clock (unused; combinational logic)
    input  wire       rst_n     // synchronous-style reset: low clears outputs
);

  // Player A: ui_in[3:0] = card0 rank, ui_in[7:4] = card1 rank (0=2 .. 12=Ace)
  // Player B: uio_in[3:0], uio_in[7:4] — bidirectional pins used as inputs

  wire [3:0] a0 = ui_in[3:0];
  wire [3:0] a1 = ui_in[7:4];
  wire [3:0] b0 = uio_in[3:0];
  wire [3:0] b1 = uio_in[7:4];

  wire [3:0] a_hi = (a0 >= a1) ? a0 : a1;
  wire [3:0] a_lo = (a0 >= a1) ? a1 : a0;
  wire [3:0] b_hi = (b0 >= b1) ? b0 : b1;
  wire [3:0] b_lo = (b0 >= b1) ? b1 : b0;

  wire a_pair = (a0 == a1);
  wire b_pair = (b0 == b1);

  // Pair (MSB=1) always beats non-pair; within same class, numeric compare is correct.
  wire [8:0] str_a = a_pair ? {1'b1, a_hi, a_hi} : {1'b0, a_hi, a_lo};
  wire [8:0] str_b = b_pair ? {1'b1, b_hi, b_hi} : {1'b0, b_hi, b_lo};

  wire raw_a_win = (str_a > str_b);
  wire raw_b_win = (str_b > str_a);
  wire raw_tie   = (str_a == str_b);

  wire active = ena & rst_n;

  assign uo_out[0] = active & raw_a_win;
  assign uo_out[1] = active & raw_b_win;
  assign uo_out[2] = active & raw_tie;
  assign uo_out[3] = active & a_pair;
  assign uo_out[4] = active & b_pair;
  assign uo_out[7:5] = 3'b000;

  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

endmodule
