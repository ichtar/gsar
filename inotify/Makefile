VER := $(shell git rev-parse --short HEAD)

all: 
	@docker build --no-cache . -t inotify:$(VER)
