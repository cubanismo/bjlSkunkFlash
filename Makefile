PROGS = bjlSkunkFlash patchbin

all: $(PROGS)

patchbin: patchbin.cpp
	g++ -o $@ -g -O0 $^

bjlSkunkFlash: bjlSkunkFlash.cpp
	g++ -o $@ -g -O0 $^

.PHONY: clean
clean:
	rm -f $(PROGS)
