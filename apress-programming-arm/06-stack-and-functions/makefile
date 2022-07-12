
OBJS = stack-and-functions.o hex2str.o toupper.o framepointer.o
MACRO_OBJS = macros.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: stack-and-functions.out macros.out

stack-and-functions.out: $(OBJS)
	ld -o stack-and-functions.out $(LDFLAGS) $(OBJS)

macros.out: $(MACRO_OBJS)
	ld -o macros.out $(LDFLAGS) $(MACRO_OBJS)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

