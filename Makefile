IMAGE_NAME=dukebarman/ghidra-builder
DEPS=Dockerfile

bash: .image_build
	docker run -it \
		--volume ${PWD}:/files \
		--workdir /files \
		--user dockerbot:dockerbot \
		--rm $(IMAGE_NAME) \
		bash

.image_build: $(DEPS)
	docker build --pull --tag $(IMAGE_NAME) .
	touch .image_build

clean:
	rm -f .image_build
	rm -f workdir/out/*
