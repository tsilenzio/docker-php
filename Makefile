.PHONY: all build clean

all: build publish

build:
	./compiler.sh --build

release:
	./compiler.sh --release