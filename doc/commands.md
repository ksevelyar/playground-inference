# commands

## `rocm-server`
Start llama.cpp server with ROCm GPU acceleration, the main command which allow to connect opencode or other agent using `http://127.0.0.1:8080/v1`.

llama-ui for chats available in browser using `http://127.0.0.1:8080`

```
Server listening on http://0.0.0.0:8080
```

## `cpu-server`
Start llama.cpp server on CPU only.
```
Server listening on http://0.0.0.0:8080
```

## `download-model`
Download a model file from a URL to `./downloads/models/`.

```
download-model https://huggingface.co/unsloth/Qwen3.6-27B-MTP-GGUF/resolve/main/Qwen3.6-27B-Q3_K_M.gguf
```
```
Saving to: './downloads/models/Qwen3.6-27B-Q3_K_M.gguf'
[ ==========> ] 100% 13.8 GiB / 13.8 GiB
```

## `benchmark-prompt`
Run a prompt file from `./prompts/` and save the result to `./bench/`.

This task measures tokens per second and allow to review quality by reading bench/ output.

```
benchmark-prompt asteroids
```
```
Wrote ./bench/Qwen3.6-27B-Q3_K_M-asteroids.md
```

## `benchmark-model`
Benchmark prompt processing and text generation throughput. This task measures only tokens per second.
```
benchmark-model
```
```
=== Benchmark: Qwen3.6-27B-Q3_K_M.gguf ===
ggml_cuda_init: found 2 ROCm devices (Total VRAM: 31783 MiB):
  Device 0: AMD Radeon RX 9060 XT, gfx1200 (0x1200), VMM: no, Wave Size: 32, VRAM: 16304 MiB
  Device 1: AMD Ryzen 7 7700 8-Core Processor, gfx1036 (0x1036), VMM: no, Wave Size: 32, VRAM: 15479 MiB
| model                          |       size |     params | backend    | ngl |     sm | fa |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | -----: | -: | --------------: | -------------------: |
| qwen35 27B Q3_K - Medium       |  12.86 GiB |    27.32 B | ROCm       | 999 |   none |  1 |           pp512 |        575.44 ± 2.49 |
| qwen35 27B Q3_K - Medium       |  12.86 GiB |    27.32 B | ROCm       | 999 |   none |  1 |           tg128 |         17.24 ± 0.02 |

build: b64739e (9190)
```

## `oneshot`
Generate a single response.
```
oneshot "say hello in spanish"
```
```
¡Hola!
```

## `chat`
Interactive chat session.
```
chat "your role is a helpful assistant"
```
```
<opens interactive REPL, type messages, Ctrl+C to exit>
```

## Env
All commands use MODEL env, you can override MODEL with `MODEL=Qwen3-14B-Q4_K_M.gguf benchmark-model`

Model should be present in downloads/models/

