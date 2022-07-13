
MACRO_OBJS = macros.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: macros.out

macros.out: $(MACRO_OBJS)
	ld -o macros.out $(LDFLAGS) $(MACRO_OBJS)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

clean:
	rm -rf *.o

