# Sample testbench for a Tiny Tapeout project

This is a sample testbench for a Tiny Tapeout project. It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.
See below to get started or for more information, check the [website](https://tinytapeout.com/hdl/testing/).

## Setting up

1. Edit [Makefile](Makefile) and modify `PROJECT_SOURCES` to point to your Verilog files.
2. Edit [tb.v](tb.v) and replace `tt_um_example` with your module name.

### Python version (cocotb)

- **Recommended:** Python **3.12** or **3.13** — `pip install -r requirements.txt` works as usual.
- **Python 3.14+:** cocotb 2.0.1 refuses the version unless you opt in (it still builds and runs for many setups):

  ```sh
  COCOTB_IGNORE_PYTHON_REQUIRES=1 pip install -r requirements.txt
  ```

- **`make: cocotb-config: Command not found`:** activate the venv you used for pip, or put it first on `PATH`, e.g. `PATH="$(pwd)/../venv/bin:$PATH" make` from the `test/` directory.

## How to run

To run the RTL simulation:

```sh
make -B
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/{your_module_name}.v` to `gate_level_netlist.v`.

Then run:

```sh
make -B GATES=yes
```

If you wish to save the waveform in VCD format instead of FST format, edit tb.v to use `$dumpfile("tb.vcd");` and then run:

```sh
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave

```sh
gtkwave tb.fst tb.gtkw
```

Using Surfer

```sh
surfer tb.fst
```
