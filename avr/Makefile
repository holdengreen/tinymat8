COMPILER = avra
PROGRAMER = atmelice_isp
SRC = the_code.asm
HEX = the_code.hex
ISP_DELAY = 2048;
MICROCONTROLLER = attiny85

do: $(SRC)
	$(COMPILER) $^
	avrdude -c $(PROGRAMER) -p $(MICROCONTROLLER) -i $(ISP_DELAY) -U flash:w:$(HEX)
