CONFIG_FILE ?= envoy-demo.yaml

docker-init:
	mkdir -p /tmp/envoy-example/config
	cp -R $(PWD)/config/* /tmp/envoy-example/config

envoy-run: docker-init
	docker run --name envoy --rm \
		-p 10000:10000 -p 10001:10001 \
		-v /tmp/envoy-example/config:/etc/envoy-example/config \
		envoyproxy/envoy:contrib-dev \
		-c /etc/envoy-example/config/$(CONFIG_FILE)

envoy-validate: docker-init
	docker run --name envoy-validate --rm \
		-v /tmp/envoy-example/config:/etc/envoy-example/config \
		envoyproxy/envoy:contrib-dev \
		--mode validate -c /etc/envoy-example/config/$(CONFIG_FILE)

envoy-bash: docker-init
	docker run --name envoy-bash --rm -it \
		-v /tmp/envoy-example/config:/etc/envoy-example/config \
		--entrypoint bash \
		envoyproxy/envoy:contrib-dev \

server-run:
	cd $(PWD)/simple-http-server; go run .
