[33m[0m<think>
Here's a thinking process:

1.  **Analyze User Input:**
   - **Topic:** Development plan for implementing Asteroids (1979) in Bevy (Rust game engine)
   - **Goals:** Decompose into tasks, optimize for economy of complexity, justify complexity before introducing it
   - **Structure Required:** Bird's-eye overview, Contract, Architecture, Task breakdown (first alpha/POC), Integration test
   - **Constraints:** Focus on decisions/responsibilities/boundaries/dependencies/rationale. Every sentence must add information/justification/risk reduction. Highly information-dense and concise. Output markdown with ## headers. Output only the plan.

2.  **Deconstruct Requirements & Constraints:**
   - *Bird's-eye overview:* High-level vision, core loop, key mechanics, why Bevy, complexity constraints.
   - *Contract:* Explicit interfaces/behaviors between systems, data flow, guarantees.
   - *Architecture:* ECS structure, component/system design, state management, rendering/audio pipeline boundaries.
   - *Task breakdown:* Phased tasks for alpha/POC, ordered by dependency, minimal viable scope.
   - *Integration test:* How to verify the system works end-to-end, test strategy, assertions.
   - *Constraints:* Every sentence must be purposeful. No fluff. Focus on decisions, responsibilities, boundaries, dependencies, rationale. Markdown headers only. Output only the plan.

3.  **Draft - Section by Section (Mental Refinement):**

   *## Bird's-eye overview*
   - Core loop: spawn ship, rotate/thrust/fire, collide with asteroids, split asteroids, track score/lives, respawn on death.
   - Complexity economy: defer particle effects, sound, menus, difficulty scaling, and high-score persistence until core physics/collision loop is stable.
   - Bevy rationale: ECS architecture naturally isolates update, collision, and rendering concerns; component-driven design prevents monolithic game objects.
   - Risk reduction: implement deterministic physics first to avoid frame-rate dependent behavior; use Bevy’s `FixedTimestep` for collision consistency.

   *## Contract*
   - Physics systems guarantee frame-rate independent position/velocity updates via `FixedTimestep`.
   - Collision system consumes `Aabb` or custom bounding shapes and emits `CollisionEvent` components; never modifies transform directly.
   - Input system maps keyboard/gamepad events to `InputAction` components; decouples raw input from game logic.
   - Spawning system reads `SpawnRequest` resources and creates entities with required components; guarantees deterministic initial states.
   - Despawn system removes entities marked `ReadyForDespawn`; prevents dangling references during physics queries.
   - All systems operate on disjoint component sets or explicit query filters to prevent ECS ordering conflicts.

   *## Architecture*
   - Entities represent discrete game objects: `Ship`, `Asteroid`, `Bullet`, `Score`, `GameMode`.
   - Components store state only: `Transform`, `Velocity`, `Rotation`, `Shape`, `Health`, `Collidable`.
   - Systems process queries: `update_physics`, `handle_collisions`, `process_input`, `manage_lifecycle`, `render_setup`.
   - State machine uses `AppWorldChildBuilder` or `State` for `Menu`, `Playing`, `GameOver`; gates system registration to active states.
   - Collision boundary: separate broadphase (grid/spatial hash) from narrowphase (circle-circle or polygon-circle); defers narrowphase to minimal circle approximation for POC.
   - Rendering boundary: `Sprite` components handle visual representation; decoupled from physics via `Transform` sync; no physics-to-rendering feedback loops.
   - Dependency graph: Input → Physics → Collision → Lifecycle → Rendering; enforced via `add_systems` ordering and `FixedTimestep` grouping.

   *## Task breakdown to implement first alpha, proof of concept*
   - T1: Initialize Bevy app with `FixedTimestep` physics loop; establishes frame-rate independence and deterministic update ordering.
   - T2: Define core components (`Transform`, `Velocity`, `Rotation`, `Collidable`, `Ship`, `Asteroid`, `Bullet`); provides data schema for ECS queries.
   - T3: Implement input mapping (`WASD`/arrows to thrust/rotate/fire); decouples raw events from action semantics.
   - T4: Build physics integration system applying velocity/rotation deltas to `Transform`; guarantees consistent motion without frame skew.
   - T5: Implement circle-based collision detection and response (`CollisionEvent` emission); isolates overlap logic from entity management.
   - T6: Create lifecycle system handling despawn, asteroid splitting (2→4→8), and ship respawn; enforces deterministic state transitions.
   - T7: Wire rendering via `Sprite` and `Camera`; separates visual output from simulation state.
   - T8: Integrate systems into `Playing` state with explicit ordering; validates dependency chain and prevents query conflicts.
   - T9: Add score tracking and game-over condition; closes core loop without UI complexity.
   - Rationale: Each task introduces minimal new components/systems; defers audio, particles, menus, and difficulty curves until core loop is stable and testable.

   *## Integration test*
   - Strategy: deterministic headless simulation with fixed seed and mocked input; verifies state transitions without rendering overhead.
   - Setup: initialize app, inject `TestInput` resource, run `FixedTimestep` loop for N frames, assert component states.
   - Assertions: verify ship rotation matches input thrust; confirm bullet spawns on fire event; assert asteroid splits on collision; validate score increments correctly; ensure game-over triggers at zero lives.
   - Execution: `bevy::app::App` configured with `RunCondition::once()`, `world.run()` until terminal state, extract query results for validation.
   - Risk reduction: isolates physics/collision logic from OS input and rendering drivers; enables CI verification of deterministic behavior before visual polish.

4.  **Check Against Constraints:**
   - *Decompose into tasks?* Yes, T1-T9.
   - *Optimize for economy of complexity?* Explicitly stated in overview and task rationale; deferred features listed.
   - *Justify complexity before introducing it?* Each section explains why a design choice exists (e.g., FixedTimestep for determinism, circle collision for POC, state gating for system isolation).
   - *Structure matches?* Bird's-eye, Contract, Architecture, Task breakdown, Integration test. All present.
   - *Focus on decisions/responsibilities/boundaries/dependencies/rationale?* Yes, heavily emphasized throughout.
   - *Every sentence adds info/justification/risk reduction?* I'll review each sentence to ensure no fluff. I'll tighten phrasing where needed.
   - *Highly information-dense and concise?* Yes, bullet-style but structured as required. I'll ensure every line carries weight.
   - *Output markdown with ## headers, output only the plan?* Will format exactly as requested.

   Let's refine the draft to ensure maximum density and strict compliance. I'll check each sentence for fluff.

   *Refinement during drafting:*
   - Bird's-eye: Remove vague statements. Focus on core loop, complexity constraints, Bevy rationale, risk reduction.
   - Contract: Explicit interfaces, guarantees, boundaries.
   - Architecture: ECS structure, component/system roles, state management, collision/rendering boundaries, dependency ordering.
   - Tasks: Ordered by dependency, minimal scope, explicit rationale per task.
   - Integration test: Deterministic, headless, assertions, risk reduction.

   All sections look solid. I will now generate the final output, carefully checking sentence-by-sentence for information density and constraint compliance. I'll avoid introductory/concluding remarks. Output only the plan. Headers exactly as requested. Markdown format. Every sentence justified. Complexity deferred explicitly. Dependencies mapped. Boundaries defined. Rationale stated. Ready. 
   Self-Correction/Verification during thought:
   - Check: "Every sentence must add information, justification, or risk reduction." -> I'll ensure no filler like "This section covers..." or "We will...". Every line must be a decision, boundary, dependency, or rationale.
   - Check: "Optimize for economy of complexity." -> Explicitly stated in task breakdown and overview. Deferral strategy documented.
   - Check: "Justify complexity before introducing it." -> Each architectural choice and task includes a "because/rationale" clause.
   - Structure: ## Bird's-eye overview, ## Contract, ## Architecture, ## Task breakdown to implement first alpha, proof of concept, ## Integration test. (Match exactly)
   - Output only the plan. No extra text.

   Proceeds to generate. 
   Output matches the refined version.✅
   Structure:
   ## Bird's-eye overview
   ## Contract
   ## Architecture
   ## Task breakdown to implement first alpha, proof of concept
   ## Integration test
   All constraints met. Information density maximized. Complexity justified. Boundaries/dependencies explicit. Ready. 
   Output generation. 
   [Output matches the response]
   *(Self-Correction/Verification during generation prep)*: I'll carefully scan each sentence to ensure it strictly meets the "every sentence must add information, justification, or risk reduction" constraint. I will remove any implicit fluff. I'll make sure the tone is technical and direct. All good.✅
   Output matches response. 
   Proceeds. 
   [Output Generation] -> *See response.* 
   *(Note: I will strictly enforce the constraint that every single sentence carries weight. I will avoid bullet points if they dilute the sentence constraint, but the prompt says "Structure should include...", so I'll use markdown lists where appropriate but ensure each bullet is a complete, information-dense sentence/phrase that meets the constraint. Actually, the constraint says "Every sentence must add...", so I'll format as paragraphs or tightly structured lists where each item is a complete declarative statement with rationale/justification.)*
   I'll structure it with clear headers and dense paragraphs/lists where each line is a complete, justified statement.
   Let's draft carefully. 
   [Done.] 
   Output Generation. 
   *(Self-Correction/Refinement during thought)*: I need to make sure the output strictly uses `##` headers and contains ONLY the plan. I will format each section as concise, high-density text. I will ensure every sentence explicitly states a decision, boundary, dependency, rationale, or risk reduction. No filler. No greetings. No conclusions.
   Ready.✅
   Output matches the final response. 
   [Proceeds]
</think>

## Bird's-eye overview
The core loop executes ship control, projectile firing, asteroid collision, fragmentation, score tracking, and respawn mechanics. Complexity economy mandates deferring audio, particle effects, menus, difficulty curves, and high-score persistence until deterministic physics and collision resolution stabilize. Bevy’s ECS model isolates update, collision, and rendering concerns, preventing monolithic game-object coupling. `FixedTimestep` enforces frame-rate independent simulation, eliminating drift and ensuring reproducible state transitions. Risk reduction prioritizes deterministic collision over visual fidelity, preventing late-stage physics refactoring. Scope boundaries exclude network play, advanced AI, and asset pipelines from the alpha target.

## Contract
Physics systems guarantee frame-rate independent integration by consuming `Velocity` and `Rotation` components and writing to `Transform` exclusively within `FixedTimestep`. Collision systems query spatial bounds, emit `CollisionEvent` resources, and never mutate `Transform` directly, preserving update ordering. Input systems translate raw OS events into `InputAction` components, decoupling hardware polling from game semantics. Spawning systems consume `SpawnRequest` resources, instantiate entities with deterministic initial components, and guarantee unique entity IDs. Despawn systems remove entities marked `ReadyForDespawn`, preventing dangling references during physics queries. All systems operate on disjoint component sets or explicit query filters to eliminate ECS ordering conflicts. State gates restrict system execution to active `GameState` variants, preventing cross-state resource leakage.

## Architecture
Entities represent discrete simulation objects: `Ship`, `Asteroid`, `Bullet`, `Score`, `GameMode`. Components store immutable state only: `Transform`, `Velocity`, `AngularVelocity`, `Shape`, `Health`, `Collidable`, `Despawn`. Systems process filtered queries: `update_physics`, `handle_collisions`, `process_input`, `manage_lifecycle`, `render_setup`. A `GameState` enum (`Menu`, `Playing`, `GameOver`) gates system registration via `RunCondition`, isolating update graphs per phase. Collision boundaries separate broadphase spatial hashing from narrowphase circle-circle approximation, deferring polygon math until core loop validation. Rendering boundaries attach `Sprite` and `Camera` components to physical entities, syncing via `Transform` without feedback loops to simulation. Dependency ordering enforces Input → Physics → Collision → Lifecycle → Rendering, validated through `add_systems` scheduling and `FixedTimestep` grouping. Resource isolation prevents shared mutable state; all cross-system communication flows through components or event buses.

## Task breakdown to implement first alpha, proof of concept
T1: Initialize Bevy app with `FixedTimestep` physics loop to establish frame-rate independence and deterministic update ordering. T2: Define core components (`Transform`, `Velocity`, `AngularVelocity`, `Collidable`, `Ship`, `Asteroid`, `Bullet`) to provide a strict data schema for ECS queries. T3: Implement input mapping translating `WASD`/arrows to thrust, rotation, and fire actions, decoupling raw events from semantic commands. T4: Build physics integration system applying velocity and angular velocity deltas to `Transform`, guaranteeing consistent motion without frame skew. T5: Implement circle-based collision detection emitting `CollisionEvent` on overlap, isolating detection logic from entity lifecycle management. T6: Create lifecycle system handling despawn, asteroid splitting (2→4→8), and ship respawn, enforcing deterministic state transitions on collision. T7: Wire rendering via `Sprite` and `Camera` components, separating visual output from simulation state to prevent render-driven physics coupling. T8: Integrate systems into `Playing` state with explicit scheduling order, validating dependency chains and eliminating query conflicts. T9: Add score tracking and game-over condition, closing the core loop without UI complexity or asset dependencies. Rationale: Each task introduces minimal new components and systems, deferring audio, particles, menus, and difficulty scaling until deterministic behavior is verified and testable.

## Integration test
Deterministic headless simulation executes with fixed seed and mocked `TestInput` resources, verifying state transitions without rendering overhead. App initialization configures `FixedTimestep`, injects test components, and runs `world.run()` until terminal `GameOver` state. Assertions verify ship rotation matches input thrust deltas, confirm bullet entity creation on fire events, assert asteroid fragmentation follows split rules, validate score increments on destruction, and ensure game-over triggers at zero lives. Execution isolates physics and collision logic from OS input drivers and GPU rendering, enabling CI verification of deterministic behavior before visual polish. Risk reduction guarantees regression detection for update ordering, collision resolution, and lifecycle transitions, preventing latent bugs in later feature integration. [end of text]


