

LOCAL_IMAGE_NAME=$(shell git remote get-url origin | cut -d ':' -f 2 | sed -e 's/.git/:local/')
TEST_IMAGE_NAME=$(shell git remote get-url origin | cut -d ':' -f 2 | sed -e 's/.git/-test/')
build-image:
	docker build --tag ${LOCAL_IMAGE_NAME} .

build-test-image:
	docker build --target tests --tag ${TEST_IMAGE_NAME} .

enter-test-image:
	docker run --rm -it -v $(CURDIR):/freqtrade --entrypoint /bin/bash ${TEST_IMAGE_NAME}
