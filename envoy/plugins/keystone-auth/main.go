package main

import (
	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm"
	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm/types"
)

func main() {
	proxywasm.SetVMContext(&vmContext{})
}

type vmContext struct {
	types.DefaultVMContext
}

func (v *vmContext) NewPluginContext(_ uint32) types.PluginContext {
	return &pluginContext{}
}

type pluginContext struct {
	types.DefaultPluginContext
}

func (p *pluginContext) NewHttpContext(_ uint32) types.HttpContext {
	return &httpContext{}
}

type httpContext struct {
	types.DefaultHttpContext
}

func (h *httpContext) OnHttpRequestHeaders(_ int, _ bool) types.Action {
	token, err := proxywasm.GetHttpRequestHeader("x-auth-token")
	if err != nil {
		proxywasm.LogDebugf("failed to get request 'x-auth-token' token: %v", err)
		return types.ActionContinue
	}

	proxywasm.LogInfof("x-auth-token: %s", token)
	return types.ActionContinue
}
