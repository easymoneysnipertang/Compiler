objects = prime fib fib_o1 fib_bridge my_fib

prime: prime.S
	arm-linux-gnueabihf-gcc prime.S -o prime
	qemu-arm -L /usr/arm-linux-gnueabihf ./prime

fib: fib.s
	arm-linux-gnueabihf-gcc fib.s -o fib
	qemu-arm -L /usr/arm-linux-gnueabihf ./fib
fib_o1: fib_O1.s
	arm-linux-gnueabihf-gcc fib_O1.s -o fib_o1
	qemu-arm -L /usr/arm-linux-gnueabihf ./fib_o1
fib_bridge: fib_bridge.s
	arm-linux-gnueabihf-gcc fib_bridge.s -o fib_bridge
	qemu-arm -L /usr/arm-linux-gnueabihf ./fib_bridge
my_fib: my_fib.s
	arm-linux-gnueabihf-gcc my_fib.s -o my_fib
	qemu-arm -L /usr/arm-linux-gnueabihf ./my_fib
	
.PHONY: clean 
clean:
	rm -fr $(objects)