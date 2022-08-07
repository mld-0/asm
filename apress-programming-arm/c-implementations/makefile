
OBJS = matrix-multiply-compiler.o 

#	Ongoing: 2022-07-15T01:09:46AEST 'DEBUGFLAG' not needed in 'ld' linking command?
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: matrix-multiply-compiler.out 

matrix-multiply-compiler.out: $(OBJS)
	ld -o matrix-multiply-compiler.out $(LDFLAGS) $(OBJS)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

%.o: %.S
	clang $(DEBUGFLGS) -arch arm64 -o $@ -c $<

clean:
	rm -rf *.o




