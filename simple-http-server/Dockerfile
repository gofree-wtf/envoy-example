FROM golang:1.20.7

COPY . /envoy-example/simple-http-server

WORKDIR /envoy-example/simple-http-server

RUN go build -o /simple-http-server .

EXPOSE 11000:11000

ENTRYPOINT /simple-http-server
