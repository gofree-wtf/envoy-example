package main

import (
	"fmt"
	"testing"

	. "envoy-example/plugins/common"

	"github.com/stretchr/testify/require"
	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm/proxytest"
	"github.com/tetratelabs/proxy-wasm-go-sdk/proxywasm/types"
)

func TestHttpAuthRandom_OnHttpRequestHeaders(t *testing.T) {
	const token = "token1"

	VMTest(t, func(t *testing.T, vm types.VMContext) {
		opt := proxytest.NewEmulatorOption().WithVMContext(vm)
		host, reset := proxytest.NewHostEmulator(opt)
		defer reset()

		// Initialize context.
		contextID := host.InitializeHttpContext()

		// Call OnHttpRequestHeaders.
		action := host.CallOnRequestHeaders(contextID,
			[][2]string{{"x-auth-token", token}}, false)
		require.Equal(t, types.ActionContinue, action)

		// Check Envoy logs.
		logs := host.GetInfoLogs()
		require.Contains(t, logs, fmt.Sprintf("x-auth-token: %s", token))
	})
}
