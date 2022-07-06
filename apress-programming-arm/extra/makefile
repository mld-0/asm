
ifdef DEBUG
DEBUGFLGS = -g
else
DEBUGFLGS =
endif

LDFLAGS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64  

all: print-register-values.out hellosilicon-printdword.out 

print-register-values.out: print-register-values.o
	ld -o print-register-values.out $(LDFLAGS) print-register-values.o

%.o: %.s
	as -arch arm64 -o $@ $<

