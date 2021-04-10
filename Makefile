

LOCAL_IMAGE_NAME=$(shell git remote get-url origin | cut -d ':' -f 2 | sed -e 's/.git/:local/')
build-image:
	docker build --tag ${LOCAL_IMAGE_NAME} .
