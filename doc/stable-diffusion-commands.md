# stable-diffusion commands

## `generate`
Generate an image from a prompt string using the model specified by `SD_MODEL`.

Models are auto-downloaded on first run.

```
SD_MODEL=Krea2-Turbo generate "Top-down view pixel art retro Asteroids game spaceship sprite"
```
```
Saved: graphics/output/krea2-turbo/2026-06-28_22-04-58.png
```

## `generate-from-prompt`
Generate an image from a prompt file in `./graphics/prompts/`.

```
SD_MODEL=Krea2-Turbo generate-from-prompt asteroids
```
```
Saved: graphics/output/krea2-turbo/2026-06-28_22-04-58-asteroids.png
```
