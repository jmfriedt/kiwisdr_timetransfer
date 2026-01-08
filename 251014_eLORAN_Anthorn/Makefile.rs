LIST = 1 2 3
all: 
	mkoctfile  -DOCTAVE  rs30_10_decode.cc -Ilibfec libfec/libfec.a
	mkoctfile  -DOCTAVE  rs30_10_encode.cc -Ilibfec libfec/libfec.a
	for i in $(LIST); do \
            echo "CASE" $$i; \
	    gcc -o rs30_10 rs30_10_encode.cc -Ilibfec -Llibfec -DCASE=$$i -lfec ;\
            ( LD_LIBRARY_PATH=./libfec ./rs30_10 ) ; \
        done
