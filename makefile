-include .creds

BASEIMAGE := xycarto/sea-draining
IMAGE := $(BASEIMAGE):2023-10-09

RUN ?= docker run -it --rm --net=host --user=$$(id -u):$$(id -g) \
	-e DISPLAY=$$DISPLAY \
	-e HOME=/work \
	--env-file .creds \
	-e RUN= -v$$(pwd):/work \
	-w /work $(IMAGE)

.PHONY: 

##### CATCHMENTS #####
watershed-clip:
	$(RUN) python3 src/clip-by-watershed.py

merges:
	$(RUN) python3 src/merge-vectors.py

burn-poly:
	$(RUN) bash src/burn-polys.sh $(tif)

rivers:
	$(RUN) bash src/grass-build-rivers.sh $(tif)

##### DOCKER #####
test-local: docker/Dockerfile
	docker run -it --rm  \
	--user=$$(id -u):$$(id -g) \
	-e DISPLAY=$$DISPLAY \
	--env-file .creds \
	-e RUN= -v$$(pwd):/work \
	-w /work $(IMAGE)
	bash
	
docker-local: docker/Dockerfile
	docker build --tag $(BASEIMAGE) - < docker/Dockerfile  && \
	docker tag $(BASEIMAGE) $(IMAGE)

docker-push: docker/Dockerfile
	echo $(DOCKER_PW) | docker login --username xycarto --password-stdin
	docker build --tag $(BASEIMAGE) - < docker/Dockerfile  && \
	docker tag $(BASEIMAGE) $(IMAGE) && \
	docker push $(IMAGE)

docker-pull:
	echo $(DOCKER_PW) | docker login --username xycarto --password-stdin
	docker pull $(IMAGE)