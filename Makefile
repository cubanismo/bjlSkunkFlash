
bjlSkunkFlash: bjlSkunkFlash.cpp
	g++ -o $@ -g -O0 $^

.PHONY: clean
clean:
	rm -f bjlSkunkFlash
