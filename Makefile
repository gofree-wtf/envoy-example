docker-init:
	mkdir -p /tmp/envoy-example/config
	cp -R $(PWD)/config/* /tmp/envoy-example/config

envoy-run: docker-init
	docker run --name envoy --rm \
		-p 32000:10000 \
		-v /tmp/envoy-example/config:/etc/envoy-example/config \
		envoyproxy/envoy:contrib-dev \
		-c /etc/envoy-example/config/envoy-demo.yaml

envoy-bash: docker-init
	docker run --name envoy-bash --rm -it \
		-v /tmp/envoy-example/config:/etc/envoy-example/config \
		--entrypoint bash \
		envoyproxy/envoy:contrib-dev \
