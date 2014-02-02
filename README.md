
About ASSEM
==========================================================================

ASSEM is a classic assembler for MERA 400.

It supports syntax used in original ASSK and ASSM assembler sources, with both K-202 and MERA 400 mnemonics.
Additionaly, it can translate classic-syntax sources into modern-syntax, similar (but not identical) to
the one used by EMAS.

Requirements
==========================================================================

To build and run assem you need:

* cmake
* GNU make
* bison and flex

Build instructions
==========================================================================

Do the following in the directory where this README lives:

```
	cmake .
	make
	make install
```

Usage
==========================================================================

Usage: `assem [options] <input.asm> [output]`

Available options are:

* -k: use K-202 mnemonics (instead of MERA-400)
* -l: write labels to output.lab file
* -p: write preprocessor output to output.pp.asm file
* -2: use K-202 mnemonics in preprocessor output (instead of MERA-400)
* -v: print version information and exit
* -h: print help
* -d: enable debug messages (lots of)

