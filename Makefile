ENVOY_CONFIG_FILENAME ?= envoy-demo.yaml
NGINX_CONFIG_FILENAME ?= default.conf

docker-init:
	mkdir -p /tmp/envoy-example
	cp -R $(PWD)/* /tmp/envoy-example

docker-up: docker-init
	docker-compose -f docker-compose.yaml up -d

docker-stop:
	docker-compose -f docker-compose.yaml stop

locust-envoy: docker-init
	docker-compose -f locust-envoy.yaml up

locust-nginx: docker-init
	docker-compose -f locust-nginx.yaml up
