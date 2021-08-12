enable-docker-experimental:
	@echo "{\"experimental\": true}" | sudo tee /etc/docker/daemon.json > /dev/null
	@sudo service docker restart || sudo systemctl restart docker

clean:
	@rm -rf src target

checkout:
	@git clone https://github.com/gohugoio/hugo.git src

docker-pull:
	@docker pull golang:1.16-buster

compile:
	@docker run --rm -i \
		-v $$(pwd):/work \
		-w /work/src \
		-u $$(id -u) \
		-e GOCACHE=/tmp/.cache \
		-e HUGO_VENDOR="$${HUGO_VENDOR:-}" \
		-e HUGO_TYPE="$${HUGO_TYPE:-standard}" \
		golang:1.16-buster \
		/work/bin/compile

copy:
	@cp src/LICENSE src/README.md target/bundle/

package:
	@cd target/bundle && tar -cvf ../bundle.tar *
	@gzip -9 target/bundle.tar