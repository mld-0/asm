
OBJS = neon-simd.o distance4d.o
OBJS_matmul = matrix-multiply-neon.o

#	Ongoing: 2022-07-15T01:09:46AEST 'DEBUGFLAG' not needed in 'ld' linking command?
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: neon-simd.out matrix-multiply-neon.out

neon-simd.out: $(OBJS)
	ld -o neon-simd.out $(LDFLAGS) $(OBJS)

matrix-multiply-neon.out: $(OBJS_matmul)
	ld -o matrix-multiply-neon.out $(LDFLAGS) $(OBJS_matmul)

%.o: %.s
	as $(DEBUGFLGS) -arch arm64 -o $@ $<

%.o: %.S
	clang $(DEBUGFLGS) -arch arm64 -o $@ -c $<

clean:
	rm -rf *.o



