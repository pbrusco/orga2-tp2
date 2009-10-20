NASM=nasm
NASMFLAGS= -f elf
OBJECTS = bordes.o asmSobel.o asmRoberts.o asmPrewitt.o asmFreichen.o
.PHONY: all clean 

all: bordes clean

bordes: $(OBJECTS)
	gcc  $(OBJECTS) -o bordes `pkg-config --cflags --libs opencv`

bordes.o: bordes.c
	gcc  -c bordes.c -o bordes.o `pkg-config --cflags opencv`

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJECTS)
	

