VER := $(shell git rev-parse --short HEAD)

all: 
	cd inotify; \
	docker build --no-cache . -t inotify:$(VER) -t inotify:latest


