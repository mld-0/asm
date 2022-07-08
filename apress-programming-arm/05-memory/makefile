
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: memory.out 

memory.out: memory.o
	ld -o memory.out $(LDFLAGS) memory.o

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<


