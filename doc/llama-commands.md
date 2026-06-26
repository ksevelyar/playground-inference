# llama commands

## `rocm-server`
Start llama.cpp server with ROCm GPU acceleration, the main command which allow to connect opencode or other agent using `http://127.0.0.1:8080/v1`.

llama-ui for chats available in browser using `http://127.0.0.1:8080`

```
Server listening on http://0.0.0.0:8080
```

## `benchmark-prompt`
Run a prompt file from `./text/prompts/` and save the result to `./text/bench/`.

This task measures tokens per second and allow to review quality by reading bench/ output.

```
benchmark-prompt asteroids
```
```
Wrote ./text/bench/Qwen3.6-27B-Q3_K_M-asteroids.md
```

## `oneshot`
Generate a single response.
```
oneshot "say hello in Spanish"
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
<opens interactive REPL>
```

## Env
All commands use MODEL env, you can override MODEL with `MODEL=Qwen3-14B-Q4_K_M benchmark-model`.

Model is auto-downloaded from Hugging Face on first run.

