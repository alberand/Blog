
DIRS = $(shell find . -maxdepth 1 ! -path . -type d)
ARCHS = $(DIRS:%=%.tar)

all: $(ARCHS)
	@echo $(ARCHS)

%.tar: %
	tar -cvzf "$@" "$<"

clean:
	rm -rf ./*.tar
