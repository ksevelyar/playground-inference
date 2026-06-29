

<think>
Here's a thinking process:

1.  **Analyze User Input:**
   - **Goal:** Produce a development plan for implementing Asteroids (1979) in Bevy.
   - **Goals:** Decompose into tasks, optimize for economy of complexity, justify complexity before introducing it.
   - **Structure:** Bird's-eye overview, Contract, Architecture, Task breakdown (first alpha/POC), Integration test.
   - **Constraints:** Focus on decisions, responsibilities, boundaries, dependencies, rationale. Every sentence must add information, justification, or risk reduction. Highly information-dense and concise. Output markdown with `##` headers. Output only the plan.

2.  **Deconstruct Requirements:**
   - *Bird's-eye overview:* High-level summary of the game, core loop, and implementation strategy.
   - *Contract:* API/interface definitions, component/resource structures, explicit boundaries between systems.
   - *Architecture:* Bevy ECS patterns, system organization, state management, rendering/audio pipeline.
   - *Task breakdown:* Phased tasks for alpha/POC, ordered by dependency, with clear milestones.
   - *Integration test:* How to verify the POC works end-to-end.
   - *Constraints:* Strict focus on decisions, responsibilities, boundaries, dependencies, rationale. Every sentence must be information-dense. No fluff. Markdown with `##` headers only.

3.  **Draft - Section by Section (Mental Refinement):**

   *## Bird's-eye Overview*
   - Core gameplay: Player rotates/accelerates ship, shoots bullets, destroys asteroids that split into smaller pieces, wraps around screen edges.
   - Implementation strategy: Minimal ECS footprint. Use Bevy's built-in physics (or custom kinematic movement) to avoid heavy dependencies. Prioritize deterministic movement and collision detection over polish.
   - Rationale: Asteroids is fundamentally a kinematic simulation with simple AABB/circle collision. Introducing a physics engine introduces unnecessary complexity; custom velocity integration suffices.
   - Scope for alpha: Ship movement, bullet firing, asteroid spawning/splitting, screen wrapping, basic collision, score tracking.
   - Risk reduction: Decouple rendering from simulation by using transform-driven rendering; isolate collision logic from movement systems.

   *## Contract*
   - Define explicit component boundaries: `Ship`, `Bullet`, `Asteroid`, `Velocity`, `Rotation`, `Sprite`, `Score`.
   - Systems interface: Movement systems query `(Entity, &Transform, &mut Velocity, &Rotation)`. Collision systems query `(Entity, &Transform, &Shape, &mut Health)`.
   - Resource contract: `GameSettings` holds constants (max speed, bullet lifetime, spawn rates). `GameState` tracks active entities and score.
   - Dependency rules: Collision systems depend on movement systems via Bevy's `run_conditions` or explicit ordering; rendering depends on transforms only.
   - Rationale: Strict component separation prevents data coupling; explicit resource boundaries enable deterministic simulation; ordering guarantees prevent race conditions in ECS.

   *## Architecture*
   - ECS structure: Flat component model. No nested entities. Ship, bullets, asteroids share `Transform`, `Velocity`, `Shape`.
   - Movement: Kinematic integration system applies `Velocity` to `Translation` and `Rotation` to `Rotation` each frame. Delta time scaling ensures frame-rate independence.
   - Collision: Broad-phase grid partitioning reduces O(N²) checks. Narrow-phase uses circle-circle distance checks. Rationale: Asteroids are circular; grid partitioning scales linearly with entity count and avoids physics engine overhead.
   - State management: `AppStates` for menu, playing, game over. Systems gated by state. Rationale: Clean lifecycle separation prevents systems from executing during inactive phases.
   - Rendering: `SpriteBundle` with pre-baked textures. No dynamic batching needed. Rationale: Static assets eliminate runtime texture management complexity.
   - Audio: Event-driven spawning of sound effects via `AudioSink`. Rationale: Decouples audio from simulation; Bevy's audio plugin handles mixing automatically.

   *## Task Breakdown*
   - Phase 1: Core Simulation (POC)
     - Task 1.1: Implement `Velocity` component and kinematic movement system. Rationale: Establishes frame-rate independent motion; foundational for all entities.
     - Task 1.2: Implement screen wrapping logic. Rationale: Core Asteroids mechanic; prevents entity loss; simple modulo arithmetic on transforms.
     - Task 1.3: Implement ship rotation and thrust input handling. Rationale: Direct player control mapping; isolates input from movement.
     - Task 1.4: Implement bullet spawning system with lifetime despawn. Rationale: Validates entity creation/despawn pipeline; introduces resource limits.
   - Phase 2: Collision & Gameplay Loop
     - Task 2.1: Implement circle collision detection system. Rationale: Matches asteroid geometry; O(N²) acceptable for <50 entities; avoids physics dependency.
     - Task 2.2: Implement asteroid splitting logic (destroy large, spawn two medium). Rationale: Core mechanic; tests entity spawning during collision resolution.
     - Task 2.3: Implement score tracking and game-over state transition. Rationale: Closes gameplay loop; validates state machine integration.
   - Phase 3: Polish & Validation
     - Task 3.1: Integrate sprites and audio events. Rationale: Completes sensory feedback; tests event-driven architecture.
     - Task 3.2: Profile collision system; optimize if frame time exceeds 2ms. Rationale: Ensures 60fps target; validates complexity economy.

   *## Integration Test*
   - Test scenario: Spawn ship, 3 large asteroids, fire 5 bullets, verify collisions, splits, score update, and screen wrapping.
   - Validation steps: 
     1. Assert ship transform updates correctly with input.
     2. Assert bullets spawn at ship orientation, despawn after lifetime.
     3. Assert asteroid collision triggers split event; new asteroids inherit velocity offset.
     4. Assert screen wrapping preserves velocity continuity across boundaries.
     5. Assert score increments on destruction; game-over triggers on ship collision.
   - Rationale: Covers movement, spawning, collision, splitting, wrapping, and state transitions; validates system integration without external dependencies.
   - Risk reduction: Automated Bevy integration test using `App` builder and `update()` loop; prevents regression during refactoring.

4.  **Check Against Constraints:**
   - *Decompose into tasks?* Yes, phased breakdown.
   - *Optimize for economy of complexity?* Yes, explicit choices against physics engine, flat ECS, grid partitioning, static assets.
   - *Justify complexity before introducing it?* Yes, each architectural/contract choice includes rationale.
   - *Structure matches?* Bird's-eye, Contract, Architecture, Task breakdown, Integration test. All present.
   - *Focus on decisions, responsibilities, boundaries, dependencies, rationale?* Yes, heavily emphasized.
   - *Every sentence adds information/justification/risk reduction?* I'll review and tighten sentences to ensure zero fluff.
   - *Highly information-dense and concise?* Yes, bullet-style but in prose/structured format. I'll ensure strict conciseness.
   - *Output markdown with ## headers, output only the plan?* Yes.

   Let's refine the draft to strictly meet the "every sentence must add information, justification, or risk reduction" constraint. I'll remove any conversational filler, ensure tight phrasing, and verify technical accuracy for Bevy.

   *Self-Correction/Refinement during drafting:*
   - Check Bevy specifics: Bevy uses `Transform` (now `GlobalTransform`/`Transform` in 0.13+), `SpriteBundle`, `AppStates` (deprecated in 0.13, replaced by `States` or `RunConditions`). I should use modern Bevy terms: `RunConditions`, `AppStates` is legacy, so I'll specify `GameState` resource with `run_conditions` or Bevy's `States` system if applicable. Actually, Bevy 0.13+ uses `App::add_systems` with `run_condition` or `States`. I'll stick to `GameState` resource + `run_conditions` for simplicity and economy.
   - Collision: Bevy's `bevy_mod_picking` or `bevy_rapier` are heavy. Custom circle collision is correct for economy.
   - I'll ensure every sentence explicitly ties to a decision, boundary, dependency, or rationale.
   - I'll structure strictly with `##` headers.
   - I'll remove any introductory/concluding text.

   Draft generation (mental):
   ## Bird's-eye Overview
   Asteroids requires kinematic movement, circular collision, entity splitting, and screen wrapping. Implementation prioritizes deterministic simulation over physics engine integration. Custom velocity integration replaces rigid body dynamics, eliminating dependency overhead. Flat entity hierarchy prevents transform nesting complexity. Systems decouple input, movement, collision, and rendering via explicit component boundaries. Alpha scope limits to core mechanics; polish defers to post-alpha validation. Risk reduction isolates simulation from presentation; frame-rate independence guarantees deterministic behavior across hardware.

   ## Contract
   Components define strict data boundaries: `Velocity` (linear/angular), `Shape` (radius), `Lifetime` (despawn timer), `Health` (destruction threshold). Systems query minimal component sets; movement systems read `Velocity` and write `Transform`; collision systems read `Shape` and `Transform`, write `Health` and spawn events. Resources enforce global constraints: `GameConfig` stores constants; `GameState` tracks phase and score. Dependencies flow unidirectionally: input → movement → collision → state/rendering. Rationale prevents circular queries; explicit ownership eliminates ECS race conditions; resource centralization enables configuration hot-reloading.

   ## Architecture
   ECS layout uses flat components shared across ship, bullets, and asteroids. Movement system integrates velocity each frame using `delta_time` scaling; screen wrapping clamps coordinates to viewport bounds. Collision system employs spatial grid partitioning; cells size equals maximum asteroid diameter; narrow-phase checks circle-circle distance. Rationale reduces O(N²) checks to O(N) while maintaining accuracy. State machine gates systems via `run_conditions`; only active-phase systems execute. Rendering binds `SpriteBundle` to `Transform`; audio triggers via `EventWriter` on collision/despawn. Rationale decouples simulation from sensory output; event-driven audio prevents frame-blocking I/O.

   ## Task Breakdown
   Phase 1 establishes simulation foundation. Task 1.1 implements `Velocity` component and kinematic integration system; validates frame-rate independent motion. Task 1.2 implements viewport wrapping; prevents entity loss and enforces boundary continuity. Task 1.3 maps input to ship rotation/thrust; isolates player control from movement pipeline. Task 1.4 spawns bullets with orientation inheritance and lifetime despawn; validates entity lifecycle management. Phase 2 closes gameplay loop. Task 2.1 implements grid-partitioned collision detection; scales linearly with entity count. Task 2.2 implements asteroid splitting logic; destroys parent, spawns two children with velocity offset. Task 2.3 tracks score and transitions to game-over state; validates resource mutation and state gating. Phase 3 integrates feedback. Task 3.1 binds sprites and audio events; tests event-driven decoupling. Task 3.2 profiles collision system; optimizes grid cell size if frame time exceeds 2ms.

   ## Integration Test
   Test scenario spawns ship, three large asteroids, and executes five bullet firings. Validation asserts ship transform updates match input; bullets spawn at correct orientation and despawn after lifetime; collisions trigger splits with inherited velocity offsets; screen wrapping preserves momentum across boundaries; score increments on destruction; game-over triggers on ship impact. Rationale covers movement, spawning, collision, splitting, wrapping, and state transitions. Automated Bevy `App` builder runs deterministic `update()` cycles; asserts component states post-execution. Risk reduction prevents regression during refactoring; validates system ordering and dependency contracts.

5.  **Final Constraint Check:**
   - Decompose into tasks? Yes, phased breakdown with explicit tasks.
   - Optimize for economy of complexity? Yes, custom movement, flat ECS, grid collision, no physics, event-driven audio.
   - Justify complexity before introducing it? Yes, every architectural/contract choice has explicit rationale.
   - Structure matches? Yes, exactly the 5 sections.
   - Focus on decisions, responsibilities, boundaries, dependencies, rationale? Yes, heavily embedded.
   - Every sentence adds info/justification/risk reduction? Checked. No filler. Each sentence states a fact, decision, boundary, dependency, or rationale.
   - Highly information-dense and concise? Yes.
   - Output markdown with ## headers, output only the plan? Yes.

   All constraints met. Proceeds to output. 
   One minor adjustment: Ensure Bevy terminology is precise. `Transform` is standard. `run_conditions` is correct for gating. `EventWriter` is standard. The text is tight. I'll output exactly as refined.✅
   Output matches the refined draft. 
   Proceeds. 
   [Output Generation] -> *See response.* 
   Self-Correction/Verification during thought: 
   - Check "Every sentence must add information, justification, or risk reduction." I'll scan each sentence to ensure it strictly adheres. 
   - "Asteroids requires kinematic movement..." -> Info/Decision
   - "Implementation prioritizes deterministic simulation..." -> Decision/Rationale
   - "Custom velocity integration replaces rigid body dynamics..." -> Decision/Risk reduction
   - All sentences pass. 
   - Structure exactly matches request. 
   - Output only the plan. 
   Ready. 
   [Output Generation] -> *Proceeds.* 
   *(Self-Correction/Refinement during output prep)*: I'll make sure the formatting strictly uses `##` for section headers as requested. I'll verify no extra text exists. The draft is solid. Output matches exactly. 
   [Output Generation] -> *Proceeds.*
</think>

## Bird's-eye Overview
Asteroids requires kinematic movement, circular collision, entity splitting, and screen wrapping. Implementation prioritizes deterministic simulation over physics engine integration. Custom velocity integration replaces rigid body dynamics, eliminating dependency overhead and build-time variability. Flat entity hierarchy prevents transform nesting complexity and simplifies collision queries. Systems decouple input, movement, collision, and rendering via explicit component boundaries. Alpha scope limits to core mechanics; polish defers to post-alpha validation. Risk reduction isolates simulation from presentation; frame-rate independence guarantees deterministic behavior across hardware.

## Contract
Components define strict data boundaries: `Velocity` stores linear and angular rates; `Shape` stores radius; `Lifetime` stores despawn timer; `Health` stores destruction threshold. Systems query minimal component sets; movement systems read `Velocity` and write `Transform`; collision systems read `Shape` and `Transform`, write `Health` and emit spawn events. Resources enforce global constraints: `GameConfig` stores constants; `GameState` tracks phase and score. Dependencies flow unidirectionally: input → movement → collision → state/rendering. Rationale prevents circular queries; explicit ownership eliminates ECS race conditions; resource centralization enables configuration hot-reloading.

## Architecture
ECS layout uses flat components shared across ship, bullets, and asteroids. Movement system integrates velocity each frame using `delta_time` scaling; screen wrapping clamps coordinates to viewport bounds. Collision system employs spatial grid partitioning; cell size equals maximum asteroid diameter; narrow-phase checks circle-circle distance. Rationale reduces O(N²) checks to O(N) while maintaining accuracy. State machine gates systems via `run_conditions`; only active-phase systems execute. Rendering binds `SpriteBundle` to `Transform`; audio triggers via `EventWriter` on collision/despawn. Rationale decouples simulation from sensory output; event-driven audio prevents frame-blocking I/O.

## Task Breakdown
Phase 1 establishes simulation foundation. Task 1.1 implements `Velocity` component and kinematic integration system; validates frame-rate independent motion. Task 1.2 implements viewport wrapping; prevents entity loss and enforces boundary continuity. Task 1.3 maps input to ship rotation/thrust; isolates player control from movement pipeline. Task 1.4 spawns bullets with orientation inheritance and lifetime despawn; validates entity lifecycle management. Phase 2 closes gameplay loop. Task 2.1 implements grid-partitioned collision detection; scales linearly with entity count. Task 2.2 implements asteroid splitting logic; destroys parent, spawns two children with velocity offset. Task 2.3 tracks score and transitions to game-over state; validates resource mutation and state gating. Phase 3 integrates feedback. Task 3.1 binds sprites and audio events; tests event-driven decoupling. Task 3.2 profiles collision system; optimizes grid cell size if frame time exceeds 2ms.

## Integration Test
Test scenario spawns ship, three large asteroids, and executes five bullet firings. Validation asserts ship transform updates match input; bullets spawn at correct orientation and despawn after lifetime; collisions trigger splits with inherited velocity offsets; screen wrapping preserves momentum across boundaries; score increments on destruction; game-over triggers on ship impact. Rationale covers movement, spawning, collision, splitting, wrapping, and state transitions. Automated Bevy `App` builder runs deterministic `update()` cycles; asserts component states post-execution. Risk reduction prevents regression during refactoring; validates system ordering and dependency contracts. [end of text]


