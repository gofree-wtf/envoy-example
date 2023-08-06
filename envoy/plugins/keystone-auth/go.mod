module envoy-example/plugins/keystone-auth

go 1.20

require (
	envoy-example/plugins/common v0.0.0
	github.com/stretchr/testify v1.8.4
	github.com/tetratelabs/proxy-wasm-go-sdk v0.22.0
)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/tetratelabs/wazero v1.0.0-rc.1 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace envoy-example/plugins/common v0.0.0 => ../common
