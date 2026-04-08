# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def pack_hand(c0: int, c1: int) -> int:
    return (c1 & 0xF) << 4 | (c0 & 0xF)


@cocotb.test()
async def test_poker_comparator(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Pair (7,7) beats high card A,K (12,11)
    dut.ui_in.value = pack_hand(7, 7)
    dut.uio_in.value = pack_hand(12, 11)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) & 0x1F == 0x09  # A wins, A pair

    # Same pair ties
    dut.ui_in.value = pack_hand(5, 5)
    dut.uio_in.value = pack_hand(5, 5)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) & 0x07 == 0x04  # tie

    # Higher pair wins
    dut.ui_in.value = pack_hand(9, 9)
    dut.uio_in.value = pack_hand(4, 4)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) & 0x07 == 0x01  # A wins

    # High card: A K beats A Q
    dut.ui_in.value = pack_hand(12, 11)
    dut.uio_in.value = pack_hand(12, 10)
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) & 0x07 == 0x01

    # When disabled, outputs low
    dut.ena.value = 0
    await ClockCycles(dut.clk, 1)
    assert int(dut.uo_out.value) == 0
