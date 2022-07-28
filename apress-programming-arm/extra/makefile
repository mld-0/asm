
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: print-register-values.out printf-line-as-char-next-overwritten.out timing-code.out
#	hellosilicon-printdword.out 

print-register-values.out: print-register-values.o
	ld -o print-register-values.out $(LDFLAGS) print-register-values.o

printf-line-as-char-next-overwritten.out: printf-line-as-char-next-overwritten.o
	ld -o printf-line-as-char-next-overwritten.out $(LDFLAGS) printf-line-as-char-next-overwritten.o

timing-code.out: timing-code.o
	ld -o timing-code.out $(LDFLAGS) timing-code.o

%.o: %.s
	as -arch arm64 -o $@ $<

