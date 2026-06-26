[33m[0m<think>
Thinking Process:

1.  **Deconstruct the Request:**
    *   Goal: Development plan for Asteroids (1979) in Bevy.
    *   Goals: Decompose tasks, optimize for economy of complexity, justify complexity.
    *   Structure: Bird's-eye overview, Contract, Architecture, Task breakdown (Alpha/POC), Integration test.
    *   Constraints: Focus on decisions/responsibilities/boundaries/dependencies/rationale. Every sentence adds info/justification/risk reduction. High information density, concise. Markdown with `##` headers. Output only the plan.

2.  **Drafting - Section by Section (Mental or rough text generation with constraint checking):**

    *   *Bird's-eye Overview:*
        *   Need to define the scope. Asteroids 1979: Ship, rotation, thrust, shooting, asteroids, collision, wrapping, scoring, levels.
        *   Economy of complexity: Start minimal. No ECS over-engineering. Use Bevy's built-in systems where possible.
        *   *Drafting:* ## Bird's-eye Overview. Asteroids 1979 requires ship control, projectile physics, asteroid splitting, screen wrapping, and collision detection. Implementation prioritizes Bevy's built-in `Transform` and `Physics` plugins to minimize custom state management. Complexity is deferred until features like particle effects or sound require explicit systems. The plan targets a functional alpha with core gameplay loop, excluding UI polish, high scores, and sound to reduce initial dependency surface area.

    *   *Contract:*
        *   What are the inputs/outputs? What defines "done"?
        *   *Drafting:* ## Contract. Inputs: Keyboard events for rotation, thrust, and firing; time delta for frame-rate independence. Outputs: Visual updates for ship, asteroids, bullets; score state; game-over condition. Boundaries: Game loop runs within a single Bevy `App`; no external assets or network code in alpha. Dependencies: `bevy`, `bevy_pbr` (optional, likely `bevy_sprite` is better for 2D economy), `bevy_input`. Rationale: `bevy_sprite` reduces shader complexity compared to `bevy_pbr` for vector-style graphics. Risk reduction: Explicit input/output contract prevents scope creep and ensures deterministic testing.

    *   *Architecture:*
        *   Bevy is ECS. How to structure?
        *   Economy: Minimal components. `Ship`, `Asteroid`, `Bullet`. Maybe `Velocity`? Or just `Transform`?
        *   Rationale: Bevy has `Physics` plugin, but for Asteroids, simple kinematic movement is sufficient. Adding `bevy_rapier` might be overkill for alpha. Better to use `Transform` and a custom `Velocity` component or just `Transform` updates.
        *   Decision: Use `Transform` + `Velocity` component for movement. Use `Collision` component or spatial queries? For alpha, manual AABB or distance check is cheaper than a physics plugin.
        *   *Drafting:* ## Architecture. Entities represent Ship, Asteroids, and Bullets. Components: `Velocity` (Vec2), `AsteroidSize` (Enum), `ShipControl` (Marker). Systems: `movement` updates `Transform` based on `Velocity`; `input` maps keys to `Velocity` changes; `collision` checks intersections; `spawn` manages waves. Rationale: Avoids `bevy_rapier` dependency, reducing build size and physics simulation overhead for non-rigid body mechanics. Spatial queries via `Query` filtering replace broad-phase physics for economy. Boundary: Systems are decoupled; input modifies velocity, movement applies velocity, collision checks state. Dependency: `collision` depends on `movement` completion; ordering enforced via `SystemSet`.

    *   *Task Breakdown (Alpha/POC):*
        *   Decompose into tasks. Justify complexity.
        *   Tasks: Setup, Ship, Movement, Shooting, Asteroids, Collision, Wrap, Game Loop.
        *   *Drafting:* ## Task Breakdown.
        *   *Task 1: Project Scaffolding.* Initialize Bevy app with `bevy_sprite` plugin. Rationale: 2D rendering is native; avoids 3D pipeline overhead.
        *   *Task 2: Ship Entity & Input.* Create ship sprite, register `KeyboardInput` system. Map Left/Right to rotation, Up to thrust vector addition. Rationale: Direct mapping reduces state complexity; thrust adds to velocity preserving momentum.
        *   *Task 3: Movement & Wrapping.* Implement `movement_system` updating `Transform.translation`. Add screen boundary check wrapping coordinates. Rationale: Wrapping is essential mechanic; manual check avoids physics plugin edge-case handling.
        *   *Task 4: Shooting Mechanics.* Spawn bullet entities with `Velocity` derived from ship direction. Remove bullets on timeout or screen exit. Rationale: Entity spawning allows scalable bullet count; timeout prevents memory leaks.
        *   *Task 5: Asteroid Generation.* Create `Asteroid` component with size enum. Spawn random positions. Rationale: Enum sizes drive splitting logic; random spawn ensures replayability.
        *   *Task 6: Collision Detection.* Query overlapping transforms between bullets/asteroids and ship/asteroids. On hit: destroy bullet, split asteroid if applicable, game over on ship hit. Rationale: Distance-based collision is sufficient for circular sprites; avoids complex polygon intersection.
        *   *Task 7: Game State & Scoring.* Track score in `Res`. Reset entities on game over. Rationale: Resource holds global state; entity despawn/respawn simplifies state transitions compared to complex state machines.

    *   *Integration Test:*
        *   How to verify?
        *   *Drafting:* ## Integration Test. Automated test runs Bevy app in headless mode. Assertions: Ship rotates correctly on input; thrust increases velocity magnitude; bullets spawn with correct direction; asteroids wrap at screen edges; collision triggers score increment and asteroid splitting; ship destruction triggers game-over state. Rationale: Headless testing validates logic without rendering overhead; assertions cover core gameplay loop ensuring functional correctness before UI integration. Risk reduction: Catches regression in movement math and collision logic early.

3.  **Review and Refine (Self-Correction/Simulation):**
    *   *Critique:* Did I mention `bevy_pbr`? I decided on `bevy_sprite`. Good.
    *   *Critique:* Is "Every sentence adds information..." met?
        *   *Check:* "Initialize Bevy app..." adds info. "Rationale: ..." adds justification. "Map Left/Right..." adds decision.
        *   *Refinement:* Ensure no fluff. Remove "The plan targets..." if redundant. Merge sentences where possible for density.
        *   *Example Refinement:* Instead of "Task 1: Project Scaffolding. Initialize Bevy app...", use "Task 1: Project Scaffolding. Initialize Bevy app with `bevy_sprite` plugin to leverage native 2D rendering and avoid 3D pipeline overhead."
        *   *Result:* Higher density.
    *   *Critique:* Structure matches requirements? Yes. `##` headers.
    *   *Critique:* Constraints? "Output only the plan." Yes.
    *   *Critique:* "Justify complexity before introducing it."
        *   *Check:* Did I justify `Velocity` component? Yes, "Rationale: ... preserves momentum." Did I justify no physics plugin? Yes, "Rationale: Avoids dependency...".
        *   *Refinement:* Ensure every architectural choice has a "Rationale" or "Risk reduction" attached.
    *   *Critique:* "Economy of complexity."
        *   *Check:* Emphasis on minimal components, no external plugins, manual collision. Good.

4.  **Final Polish (Mental Representation of Output):**
    *   *Bird's-eye:* Asteroids 1979 requires ship kinematics, projectile spawning, asteroid splitting, and screen wrapping. Implementation uses Bevy's ECS with minimal custom components to reduce state management overhead. Complexity is deferred: particle effects, sound, and UI are excluded from alpha to minimize dependency surface area and accelerate proof-of-concept validation.
    *   *Contract:* Inputs: Keyboard events (rotation, thrust, fire), time delta. Outputs: Entity transforms, score resource, game-over flag. Boundaries: Single Bevy `App`; no external assets or network. Dependencies: `bevy`, `bevy_sprite`, `bevy_input`. Rationale: `bevy_sprite` provides 2D rendering without shader complexity; explicit contract prevents scope creep and enables deterministic testing.
    *   *Architecture:* Entities: Ship, Asteroid, Bullet. Components: `Velocity` (Vec2), `AsteroidSize` (Enum), `ShipMarker`. Systems: `input` updates velocity; `movement` applies velocity to `Transform`; `collision` checks intersections; `spawn` manages waves. Rationale: `Velocity` component decouples physics from rendering; `AsteroidSize` drives splitting logic without complex state machines. Risk reduction: Manual distance-based collision avoids `bevy_rapier` dependency, reducing build size and simulation overhead for circular sprites. Systems ordered via `SystemSet` to enforce input→movement→collision dependency chain.
    *   *Tasks:*
        *   Task 1: Scaffolding. Initialize `App` with `bevy_sprite`. Rationale: Native 2D support eliminates 3D pipeline overhead.
        *   Task 2: Ship Control. Register `input_system` mapping keys to `Velocity` changes; rotation updates `Transform.rotation`. Rationale: Direct input-to-velocity mapping preserves momentum; rotation via transform avoids trigonometry in velocity calculation.
        *   Task 3: Movement & Wrap. `movement_system` advances `Transform` by `Velocity * delta`. Clamp coordinates to screen bounds with wrapping. Rationale: Manual wrapping ensures correct edge behavior; delta multiplication guarantees frame-rate independence.
        *   Task 4: Shooting. `fire_system` spawns Bullet entities with `Velocity` aligned to ship rotation. Despawn bullets on timeout or boundary exit. Rationale: Entity spawning scales bullet count; timeout prevents memory leaks without spatial queries.
        *   Task 5: Asteroids. `spawn_system` creates Asteroid entities with random positions and `AsteroidSize`. Rationale: Random distribution ensures gameplay variety; size enum simplifies splitting logic.
        *   Task 6: Collision. `collision_system` queries overlapping entities via distance checks. Bullet-Asteroid: destroy bullet, split asteroid, increment score. Ship-Asteroid: game over. Rationale: Distance checks suffice for circular sprites; splitting via entity replacement avoids complex state transitions.
        *   Task 7: Game Loop. `score_resource` tracks points. Reset entities on game over. Rationale: Resource holds global state; entity reset simplifies restart logic compared to state machines.
    *   *Integration Test:* Headless Bevy execution validates core loop. Assertions: Input modifies velocity; movement updates transform; wrapping preserves position continuity; collision triggers splitting and score update; game-over halts simulation. Rationale: Headless mode isolates logic from rendering; assertions verify functional correctness of kinematics and collision, reducing regression risk before UI integration.

5.  **Final Output Construction:**
    *   Format as Markdown.
    *   Ensure `##` headers.
    *   Check density.
    *   Result looks solid.
</think>

## Bird's-eye Overview
Asteroids 1979 requires ship kinematics, projectile spawning, asteroid splitting, and screen wrapping. Implementation uses Bevy's ECS with minimal custom components to reduce state management overhead. Complexity is deferred: particle effects, sound, and UI are excluded from alpha to minimize dependency surface area and accelerate proof-of-concept validation. The plan targets a functional gameplay loop with deterministic physics and collision logic.

## Contract
**Inputs:** Keyboard events (rotation, thrust, fire), time delta for frame-rate independence.
**Outputs:** Entity transforms, score resource, game-over flag.
**Boundaries:** Single Bevy `App`; no external assets, audio, or network code in alpha.
**Dependencies:** `bevy`, `bevy_sprite`, `bevy_input`.
**Rationale:** `bevy_sprite` provides native 2D rendering without shader complexity; explicit contract prevents scope creep and enables deterministic testing. Risk reduction: Minimal dependency list reduces build failures and version conflicts.

## Architecture
**Entities:** Ship, Asteroid, Bullet.
**Components:** `Velocity` (Vec2), `AsteroidSize` (Enum), `ShipMarker` (Marker).
**Systems:** `input` updates velocity; `movement` applies velocity to `Transform`; `collision` checks intersections; `spawn` manages waves.
**Rationale:** `Velocity` component decouples physics from rendering; `AsteroidSize` drives splitting logic without complex state machines. Manual distance-based collision avoids `bevy_rapier` dependency, reducing build size and simulation overhead for circular sprites. Systems ordered via `SystemSet` to enforce input→movement→collision dependency chain. Risk reduction: Decoupled systems allow independent testing and modification.

## Task Breakdown
**Task 1: Scaffolding.** Initialize `App` with `bevy_sprite` plugin. Rationale: Native 2D support eliminates 3D pipeline overhead and simplifies sprite rendering.

**Task 2: Ship Control.** Register `input_system` mapping keys to `Velocity` changes; rotation updates `Transform.rotation`. Rationale: Direct input-to-velocity mapping preserves momentum; rotation via transform avoids trigonometry in velocity calculation.

**Task 3: Movement & Wrap.** `movement_system` advances `Transform` by `Velocity * delta`. Clamp coordinates to screen bounds with wrapping. Rationale: Manual wrapping ensures correct edge behavior; delta multiplication guarantees frame-rate independence.

**Task 4: Shooting.** `fire_system` spawns Bullet entities with `Velocity` aligned to ship rotation. Despawn bullets on timeout or boundary exit. Rationale: Entity spawning scales bullet count; timeout prevents memory leaks without spatial queries.

**Task 5: Asteroids.** `spawn_system` creates Asteroid entities with random positions and `AsteroidSize`. Rationale: Random distribution ensures gameplay variety; size enum simplifies splitting logic.

**Task 6: Collision.** `collision_system` queries overlapping entities via distance checks. Bullet-Asteroid: destroy bullet, split asteroid, increment score. Ship-Asteroid: game over. Rationale: Distance checks suffice for circular sprites; splitting via entity replacement avoids complex state transitions.

**Task 7: Game Loop.** `score_resource` tracks points. Reset entities on game over. Rationale: Resource holds global state; entity reset simplifies restart logic compared to state machines.

## Integration Test
Headless Bevy execution validates core loop. Assertions: Input modifies velocity; movement updates transform; wrapping preserves position continuity; collision triggers splitting and score update; game-over halts simulation. Rationale: Headless mode isolates logic from rendering; assertions verify functional correctness of kinematics and collision, reducing regression risk before UI integration. Risk reduction: Automated tests catch math errors and logic flaws early in development. [end of text]


