# Playground Inference

## Text Generation
[llama.cpp](https://github.com/ggml-org/llama.cpp) server tuned for agentic flow on AMD Radeon RX 9060 XT 16GB

### Run Server
```
nix develop

MODEL=Qwen3.6-27B-Q3_K_M rocm-server
```

### Connect opencode or other agent using `http://127.0.0.1:8080/v1`
```
nvim ~/.config/opencode/opencode.jsonc
```
```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "plan",
  "provider": {
    "llama.cpp": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama.cpp amd",
      "options": {
        "baseURL": "http://127.0.0.1:8080/v1"
      },
      // NOTE: llama.cpp server loads one model per process.
      // The model field in your API request is ignored; it always serves whatever it was started with.
      "models": {
        "local": {
          "name": "local"
        }
      }
    }
  },
  // NOTE: keep free cloud provider as default
  "model": "opencode/big-pickle"
}
```

[![opencode](doc/opencode.png)](https://github.com/anomalyco/opencode)

## Image Generation
```
nix develop

SD_MODEL=Krea2-Turbo generate "Top-down view pixel art retro Asteroids game spaceship sprite"
```
![krea2](graphics/output/krea2-turbo/2026-06-28_22-04-58-asteroids.png)
