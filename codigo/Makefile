NASM		= nasm
NASMFLAGS 	= -ggdb -f elf -o
CC 			= gcc
CFLAGS		= -ggdb -o
OBJECTS		= bordes.o asmSobel.o asmRoberts.o asmPrewitt.o asmFreiChen.o

.PHONY: all clean 


all: bordes clean


bordes: $(OBJECTS)
	gcc $(CFLAGS) $@ $^ `pkg-config --cflags --libs opencv`


%.o: %.c
	$(CC) -c $(CFLAGS) $@ $< `pkg-config --cflags opencv`


%.o: %.asm
	$(NASM) $(NASMFLAGS) $@ $<


clean:
	rm -f $(OBJECTS)

