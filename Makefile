enable-docker-experimental:
	@echo "{\"experimental\": true}" | sudo tee /etc/docker/daemon.json > /dev/null
	@sudo service docker restart || sudo systemctl restart docker

clean:
	@rm -rf src target

checkout:
	@git clone https://github.com/gohugoio/hugo.git src

build:
	@docker run --rm -it \
		-v $$(pwd):/work \
		-w /work/src \
		-u $$(id -u) \
		-e GOCACHE=/tmp/.cache \
		golang:1.16-buster \
		/work/bin/build

copy:
	@cp src/LICENSE src/README.md target/bundle/