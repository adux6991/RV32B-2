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


.PHONY: all, toolchain-new, toolchain-make, pk-new, pk-make, qemu-new, qemu-make, run

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
		git reset --hard 2ffda4e; \
		git submodule update --init --recursive

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
		git reset --hard fd688fc; \
		git apply $(DIR_TOP)/pk.patch

pk-make:
	@echo "Configuring pk..."
	@cd $(DIR_PK); \
		rm -rf build; \
		mkdir build; \
		cd build; \
		../configure --host=riscv32-unknown-linux-gnu
	@echo "Building pk..."
	@cd $(DIR_PK)/build; \
		make -k

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
	
qemu-make:
	@echo "Configuring qemu..."
	@cd $(DIR_QEMU); ./configure --target-list=riscv32-softmmu
	@echo "Building qemu..."
	@cd $(DIR_QEMU); make -j4

run:
	@$(DIR_QEMU)/riscv32-softmmu/qemu-system-riscv32 -machine sifive -kernel $(DIR_PK)/build/bbl -nographic
