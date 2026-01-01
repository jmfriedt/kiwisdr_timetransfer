all: crc14_cc.oct crc14_cc

crc14_cc: crc14_cc.cc
	g++ -o crc14_cc crc14_cc.cc

crc14_cc.oct: crc14_cc.cc
	mkoctfile -DOCTAVE crc14_cc.cc

clean:
	rm crc14_cc.oct crc14_cc
