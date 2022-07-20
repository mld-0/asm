
OBJS = multiply-and-divide.o

#	Ongoing: 2022-07-15T01:09:46AEST 'DEBUGFLAG' not needed in 'ld' linking command?
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: multiply-and-divide.out 

multiply-and-divide.out: $(OBJS)
	ld -o multiply-and-divide.out $(LDFLAGS) $(OBJS)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

%.o: %.S
	clang $(DEBUGFLGS) -arch arm64 -o $@ -c $<

clean:
	rm -rf *.o

