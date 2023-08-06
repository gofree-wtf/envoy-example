ENVOY_CONFIG_FILENAME ?= envoy-demo.yaml
NGINX_CONFIG_FILENAME ?= default.conf

envoy-plugins-build:
	find ./envoy/plugins -mindepth 1 -type f -name "main.go" \
		| xargs -I {} bash -c 'dirname {}' \
		| xargs -I {} bash -c 'cd {} && go mod tidy && tinygo build -o main.wasm -scheduler=none -target=wasi ./main.go'

envoy-plugins-test: envoy-plugins-build
	find ./envoy/plugins -mindepth 1 -type f -name "main.go" \
    	| xargs -I {} bash -c 'dirname {}' \
    	| xargs -I {} bash -c 'cd {} && go test ./...'

docker-init:
	mkdir -p /tmp/envoy-example
	cp -R $(PWD)/* /tmp/envoy-example

docker-up: docker-rm envoy-plugins-build docker-init
	docker-compose -f docker-compose.yaml rm -fs \
		&& docker-compose -f docker-compose.yaml up -d

docker-rm:
	docker-compose -f docker-compose.yaml rm -fs

locust-envoy: docker-init
	docker-compose -f locust-envoy.yaml up \
		&& docker-compose -f locust-envoy.yaml rm -fs

locust-nginx: docker-init
	docker-compose -f locust-nginx.yaml up \
		&& docker-compose -f locust-nginx.yaml rm -fs
