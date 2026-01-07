# gcc -o rs30_10 rs30_10.c -lfec
# all:
LIST = 1 2 3
all: 
	mkoctfile  -DOCTAVE  rs30_10_decode.cc  -Ilibfec -lfec
	mkoctfile  -DOCTAVE  rs30_10_encode.cc  -Ilibfec -lfec
	for i in $(LIST); do \
            echo "CASE" $$i; \
	    gcc -o rs30_10 rs30_10_encode.cc -I libfec/ -DCASE=$$i -lfec ;\
            (./rs30_10) ; \
        done
