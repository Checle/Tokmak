all: build

build:
	swift build

test:
	swift test

clean:
	rm -rf .build
