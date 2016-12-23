# RV32B-2

To boot a **RISCV32** dummy\_payload bbl on a **x86\_64** machine.

## Prerequisites

``` bash
sudo apt-get install gcc libc6-dev pkg-config bridge-utils uml-utilities zlib1g-dev libglib2.0-dev autoconf automake libtool libsdl1.2-dev unzip autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc
```

## Run

``` bash
make toolchain-new
make toolchain-make

make pk-new
make pk-make

make qemu-new
make qemu-make

make run
```

You can skip `toolchain-new`, `pk-new` and `qemu-new` the second time you make. They are needed only once.
