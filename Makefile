IMAGE_NAME=dukebarman/ghidra-builder
DEPS=Dockerfile

.PHONY: all
all: .image_build

.image_build: $(DEPS)
	docker build --pull --tag $(IMAGE_NAME) .
	touch .image_build

bash: .image_build
	docker run -it \
		-v ${PWD}:/files \
		-w /files \
		--user dockerbot:dockerbot \
		--rm $(IMAGE_NAME) \
		bash
