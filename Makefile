AS := as
LD := ld
ASFLAGS := --64
LDFLAGS :=

SRC := src/l0c.s
OBJ := obj/l0c.o
BIN := bin/l0c

.PHONY: all clean test

all: $(BIN)

$(OBJ): $(SRC)
	@mkdir -p obj
	$(AS) $(ASFLAGS) -o $@ $<

$(BIN): $(OBJ)
	@mkdir -p bin
	$(LD) $(LDFLAGS) -o $@ $<

clean:
	rm -rf obj bin

test: $(BIN)
	bash tests/run.sh
