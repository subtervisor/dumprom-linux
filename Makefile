# Build dumprom by repurposing the i386 COFF objects from NKCOMPR.LIB.
#
#   objconv-git/src/*.cpp                 -> build/bin/objconv
#   NKCOMPR.LIB                           -> build/coff/*.obj
#   build/coff/%.obj                      -> build/elf/%.o
#   glue.c                                -> build/glue.o
#   dumprom.cpp + glue.o + build/elf/*.o  -> dumprom

LIB         := NKCOMPR.LIB
DUMPROM     := dumprom

BUILD       := build
COFF_DIR    := $(BUILD)/coff
ELF_DIR     := $(BUILD)/elf
BIN_DIR     := $(BUILD)/bin

OBJCONV     := $(BIN_DIR)/objconv
OBJCONV_SRC := $(wildcard objconv-git/src/*.cpp)

# COFF member names come straight out of the archive.  MSVC stored them as
# "obj/x86/retail/<name>.obj"; we flatten the prefix on extraction.
COFF_NAMES  := $(notdir $(shell ar t $(LIB) 2>/dev/null))
COFF_OBJS   := $(addprefix $(COFF_DIR)/, $(COFF_NAMES))
ELF_OBJS    := $(patsubst %.obj,$(ELF_DIR)/%.o,$(COFF_NAMES))

GLUE_O      := $(BUILD)/glue.o

# i386 toolchain: the .obj code is 32-bit, and dumprom.cpp's
# `typedef unsigned long DWORD` only matches Windows when built -m32.
CXX32       := g++ -m32
CC32        := gcc -m32

.PHONY: all clean
.SUFFIXES:

all: $(DUMPROM)

# --- native objconv ---------------------------------------------------------

$(OBJCONV): $(OBJCONV_SRC) | $(BIN_DIR)
	g++ -O2 -o $@ $(OBJCONV_SRC)

# --- extract every .obj from the .lib in one shot ---------------------------
# Grouped-target rule (GNU make >= 4.3): one recipe produces all members.

$(COFF_OBJS) &: $(LIB) | $(COFF_DIR)
	cd $(COFF_DIR) && mkdir -p obj/x86/retail && ar x $(CURDIR)/$(LIB)
	mv $(COFF_DIR)/obj/x86/retail/*.obj $(COFF_DIR)/
	rm -rf $(COFF_DIR)/obj

# --- COFF -> ELF ------------------------------------------------------------
# -nu strips MSVC's leading-underscore convention so dumprom's extern "C"
#  references resolve.

$(ELF_DIR)/%.o: $(COFF_DIR)/%.obj $(OBJCONV) | $(ELF_DIR)
	$(OBJCONV) -felf32 -nu $< $@ > /dev/null

# --- glue.c -----------------------------------------------------------------

$(GLUE_O): glue.c | $(BUILD)
	$(CC32) -O2 -c $< -o $@

# --- final link -------------------------------------------------------------
# -no-pie: the converted .obj code is not position-independent, so link as
# a fixed-address executable.

$(DUMPROM): dumprom.cpp $(ELF_OBJS) $(GLUE_O)
	$(CXX32) -O2 -no-pie -w dumprom.cpp $(GLUE_O) $(ELF_OBJS) -o $@

# --- mkdirs / clean ---------------------------------------------------------

$(BUILD) $(BIN_DIR) $(COFF_DIR) $(ELF_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD) $(DUMPROM)
