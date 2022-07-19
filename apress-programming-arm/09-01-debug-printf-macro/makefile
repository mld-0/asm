
OBJS = adding.o
OBJS_EPC = example-printf-call.o

#	Ongoing: 2022-07-15T01:09:46AEST 'DEBUGFLAG' not needed in 'ld' linking command?
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: adding.out example-printf-call.out

adding.out: $(OBJS)
	ld -o adding.out $(LDFLAGS) $(OBJS)

example-printf-call.out: $(OBJS_EPC)
	ld -o example-printf-call.out $(LDFLAGS) $(OBJS_EPC)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

%.o: %.S
	clang $(DEBUGFLGS) -arch arm64 -o $@ -c $<

clean:
	rm -rf *.o


