DIR_TOP := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
DIR_TOP := $(DIR_TOP:/=)

DIR_TOOLCHAIN := $(DIR_TOP)/riscv-gnu-toolchain 
DIR_PK := $(DIR_TOP)/riscv-pk
DIR_QEMU := $(DIR_TOP)/riscv-qemu

DIR_RISCV := $(DIR_TOP)/riscv
PATH := $(DIR_RISCV)/bin:$(PATH)

REPO_TOOLCHAIN := https://github.com/riscv/riscv-gnu-toolchain
REPO_PK := https://github.com/sifive/riscv-pk
REPO_QEMU := https://github.com/riscv/riscv-qemu


.PHONY: all, toolchain-new, toolchain-make, pk-new, pk-make, qemu-new, qemu-make, run, clean

all:
	@echo
	@echo "Run the following commands in order:"
	@echo "make toolchain-new"
	@echo "make toolchain-make"
	@echo "make pk-new"
	@echo "make pk-make"
	@echo "make qemu-new"
	@echo "make qemu-make"
	@echo "make run"
	@echo
	@echo "You can skip toolchain-new, pk-new and qemu-new the second time you make."
	@echo "They are needed only once."
	@echo

toolchain-new:
	@echo "Removing old toolchain repo..."
	@rm -rf $(DIR_TOOLCHAIN)
	@echo "Fetching toolchain..."
	@git clone $(REPO_TOOLCHAIN)
	@cd $(DIR_TOOLCHAIN); \
		git reset --hard 2ffda4e

toolchain-make:
	@echo "Configuring toolchain..."
	@cd $(DIR_TOOLCHAIN); \
		./configure --with-xlen=32 --prefix=$(DIR_RISCV)
	@echo "Building toolchain..."
	@cd $(DIR_TOOLCHAIN); \
		make -j4 linux

pk-new:
	@echo "Removing old pk repo..."
	@rm -rf $(DIR_PK)
	@echo "Fetching pk..."
	@git clone $(REPO_PK)
	@cd $(DIR_PK); \
		git reset --hard fd688fc

pk-make:
	@echo "Configuring toolchain..."
	@cd $(DIR_TOOLCHAIN); \
		./configure --with-xlen=32 --prefix=$(DIR_RISCV)
	@echo "Building toolchain..."
	@cd $(DIR_TOOLCHAIN); \
		make -j4 linux
qemu-new:
	@echo "Removing old qemu repo..."
	@rm -rf $(DIR_QEMU)
	@echo "Fetching qemu..."
	@git clone $(REPO_QEMU)
	@cd $(DIR_QEMU); \
		git reset --hard fe43ef4; \
		git fetch origin pull/46/head:working; \
		git checkout working; \
		git submodule update --init pixman;\
		git apply $(DIR_TOP)/qemu.patch
	
qemu-make:
	@echo "Configuring qemu..."
	@cd $(DIR_QEMU); ./configure --target-list=riscv64-softmmu --disable-werror
	@echo "Building qemu..."
	@cd $(DIR_QEMU); make -j4

run:
	@$(DIR_QEMU)/riscv64-softmmu/qemu-system-riscv64 -kernel $(DIR_SIFIVE)/work/riscv-pk/bbl -nographic

clean:
	@echo "Cleaning..."
	@rm -rf $(DIR_QEMU) $(DIR_SIFIVE)
