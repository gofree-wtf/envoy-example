ENVOY_CONFIG_FILENAME ?= envoy-demo.yaml
NGINX_CONFIG_FILENAME ?= default.conf

docker-init:
	mkdir -p /tmp/envoy-example/envoy
	cp -R $(PWD)/envoy/* /tmp/envoy-example/envoy
	mkdir -p /tmp/envoy-example/nginx
	cp -R $(PWD)/nginx/* /tmp/envoy-example/nginx

envoy-run: docker-init
	docker run --name envoy --rm \
		-p 10000:10000 -p 10001:10001 \
		-v /tmp/envoy-example/envoy:/etc/envoy-example/envoy \
		envoyproxy/envoy:contrib-dev \
		-c /etc/envoy-example/envoy/$(ENVOY_CONFIG_FILENAME)

envoy-validate: docker-init
	docker run --name envoy-validate --rm \
		-v /tmp/envoy-example/envoy:/etc/envoy-example/envoy \
		envoyproxy/envoy:contrib-dev \
		--mode validate -c /etc/envoy-example/envoy/$(ENVOY_CONFIG_FILENAME)

envoy-bash: docker-init
	docker run --name envoy-bash --rm -it \
		-v /tmp/envoy-example/envoy:/etc/envoy-example/envoy \
		--entrypoint bash \
		envoyproxy/envoy:contrib-dev \

server-run:
	cd $(PWD)/simple-http-server; go run .

nginx-run: docker-init
	docker run --name nginx --rm \
		-p 12000:12000 \
		-v /tmp/envoy-example/nginx/$(NGINX_CONFIG_FILENAME):/etc/nginx/conf.d/default.conf \
		nginx:1.25.1

locust-init:
	pip install -r requirements.txt

locust-run-envoy:
	locust --config $(PWD)/locust/test-envoy.conf

locust-run-nginx:
	locust --config $(PWD)/locust/test-nginx.conf
