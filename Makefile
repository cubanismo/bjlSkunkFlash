PROGS = bjlSkunkFlash patchbin mkuniv

all: $(PROGS)

patchbin: patchbin.cpp
	g++ -o $@ -g -O0 $^

bjlSkunkFlash: bjlSkunkFlash.cpp
	g++ -o $@ -g -O0 $^

mkuniv: mkuniv.cpp
	g++ -o $@ -g -O0 $^

.PHONY: clean
clean:
	rm -f $(PROGS)
