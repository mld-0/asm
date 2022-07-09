OBJS = stack-and-functions.o hex2str.o toupper.o

ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: stack-and-functions.out 

stack-and-functions.out: $(OBJS)
	ld -o stack-and-functions.out $(LDFLAGS) $(OBJS)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

