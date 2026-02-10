Traverse USA Arcade for the EBAZ-4205 ZYNQ-7010 FPGA Board. Pinballwiz.org 2026
Code from DarFPGA.

Notes:
Setup for keyboard controls in Upright mode (5 = Coin) (Start P1 = 1) (Start P2 = 2)(LCtrl - Accelerate)(Arrow Keys = Move L or R)(Down Arrow = Brake)
Consult the Docs Folder for Information regarding peripheral connections and schematics.

Build:
* Obtain correct roms file for Traverse USA (see scripts in tools folder for rom details).
* Unzip rom files to the tools folder.
* Run the make travusa proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the EBAZ4205-TraverseUSA project file using Vivado (v2022.2 or silimar is recommended)
* Compile the project updating filepaths to source files as necessary.
* Connect JTAG Programmer and program EBAZ4205 Board.
