enable-docker-experimental:
	@echo "{\"experimental\": true}" | sudo tee /etc/docker/daemon.json > /dev/null
	@sudo service docker restart || sudo systemctl restart docker

clean:
	@rm -rf src target

checkout:
	@git clone --branch $${HUGO_BRANCH:-master} https://github.com/gohugoio/hugo.git src

extract-platform:
	@bin/extract-platform

docker-pull:
	@docker pull $${GOLANG_COMPILE_IMAGE:-golang:1.16-buster}
	@docker pull $${GOLANG_IMAGE:-golang:1.16-buster}

compile-standard:
	docker run --rm -i \
		-v $$(pwd):/work \
		-w /work/src \
		-u $$(id -u):$$(id -g) \
		-e GOCACHE=/tmp/.cache \
		-e HUGO_VENDOR="$${HUGO_VENDOR:-}" \
		-e HUGO_TYPE="$${HUGO_TYPE:-standard}" \
		-e GOARCH="$${GOARCH:-arm64}" \
		$${GOLANG_COMPILE_IMAGE:-golang:1.20.1-buster} \
		/work/bin/compile-standard

compile-extended:
	docker run --rm -i \
		-v $$(pwd):/work \
		-w /work/src \
		-u $$(id -u):$$(id -g) \
		-e GOCACHE=/tmp/.cache \
		-e HUGO_VENDOR="$${HUGO_VENDOR:-}" \
		-e HUGO_TYPE="$${HUGO_TYPE:-standard}" \
		-e GOARCH="$${GOARCH:-arm64}" \
		$${GOLANG_IMAGE:-golang:1.20.1-buster} \
		/work/bin/compile-extended

verify:
	@docker run --rm -i \
		-v $$(pwd):/work \
		-w /work/src \
		$${GOLANG_IMAGE:-golang:1.20.1-buster} \
		/work/target/bundle/hugo version

copy:
	@cp src/LICENSE src/README.md target/bundle/

package-bundle:
	@bin/package-bundle

bump:
	@curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r .tag_name | sed "s:^v::" | tr -d '\n' > vars/HUGO_VERSION

commit:
	@git commit -a -m "Version $$(cat vars/HUGO_VERSION)"
	@git push origin main

tag:
	@git tag -a v$$(cat vars/HUGO_VERSION)
	@git push origin v$$(cat vars/HUGO_VERSION)

test:
	@HUGO_BRANCH=v$$(cat vars/HUGO_VERSION) \
	HUGO_TYPE=extended \
	HUGO_VENDOR=test \
	make clean checkout compile verify