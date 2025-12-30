# gcc -o rs30_10 rs30_10.c -lfec
# all:
LIST = 1 2 3
all: 
	for i in $(LIST); do \
            echo "CASE" $$i; \
	    gcc -o rs30_10 rs30_10.c -I libfec/ -DCASE=$$i -lfec ;\
            (./rs30_10) ; \
        done
