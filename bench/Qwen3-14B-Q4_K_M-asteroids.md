[33m[0m<think>
Okay, the user wants a development plan for implementing the classic Asteroids game in Bevy. Let me start by recalling what Asteroids entails. The game has a spaceship that can rotate, thrust, and shoot; asteroids that split into smaller ones when hit; and a wrap-around screen. The main challenge is translating this into Bevy's ECS architecture.

First, the Bird's-eye overview. I need to outline the core systems: physics, rendering, input, and game logic. Bevy's strengths are in ECS and component-based design, so I should leverage that. The contract would involve defining the game's boundaries, like screen wrapping and collision detection. Architecture-wise, I'll need to structure entities, components, and systems. For the task breakdown, starting with a minimal alpha makes sense—maybe the ship movement and basic rendering first.

Wait, the user emphasized economy of complexity. So I should avoid adding features until necessary. For example, starting with just the ship's rotation and movement before adding shooting or asteroids. Also, justifying each complexity introduction: like why use a physics system versus manual calculations. Maybe Bevy's physics plugin is overkill for Asteroids, but using it could save time. However, the user said to justify complexity before introducing it, so maybe start with simple math for movement.

Constraints: the output must be concise, under 200 lines, with markdown sections. Each sentence should add value. Let me structure each section with headers. The contract section should define what the game must do. Architecture would detail components and systems. Task breakdown needs to be in order, starting with the proof of concept.

Potential risks: overcomplicating the physics early on. So the plan should incrementally build up, ensuring each step is justified. For example, first implement ship controls, then add asteroids, then collisions, then scoring. Also, considering Bevy's asset handling for textures and sounds, but maybe that's for later stages.

I should ensure that each part of the plan addresses dependencies. Like, before adding collision detection, the ship and asteroids must exist. Also, the wrap-around screen requires handling position components correctly. Maybe using Bevy's Transform component and custom systems to handle wrapping.

Alright, putting it all together: overview, contract, architecture, tasks. Make sure each section is concise, focused on decisions and rationale. Avoid fluff. Check line count to stay under 200. Use headers as specified. Alright, time to draft.
</think>

## Bird's-eye Overview  
Asteroids (1979) requires 2D physics, collision detection, screen wrapping, and entity spawning. Bevy's ECS architecture enables modular systems for movement, rendering, and game logic. Prioritize minimal viable physics and input handling before adding complexity like asteroid splitting or scoring.  

## Contract  
Define boundaries:  
- **Screen Wrapping**: Entities exit one edge and reappear on the opposite.  
- **Collision Detection**: Ship/missiles vs. asteroids.  
- **Entity Lifecycle**: Ship, asteroids, missiles, explosion effects.  
- **Input Mapping**: Keyboard controls for rotation, thrust, shooting.  

## Architecture  
**Entities**:  
- `Ship`: Transform, Velocity, Rotation, Thrust.  
- `Asteroid`: Transform, Velocity, Size (for splitting).  
- `Missile`: Transform, Velocity, Lifetime.  

**Systems**:  
- **Input System**: Maps keyboard events to ship rotation/thrust.  
- **Physics System**: Updates positions with velocity, applies screen wrapping.  
- **Collision System**: Checks AABB overlaps between ship/missiles and asteroids.  
- **Spawning System**: Generates asteroids at random positions/speeds.  
- **Rendering System**: Draws entities using Bevy's sprite/texture pipeline.  

**Dependencies**:  
- Input → Physics → Collision → Spawning (for asteroid generation).  
- Physics → Rendering (position updates).  

## Task Breakdown (Alpha/POC)  
1. **Core Entity Setup** (Day 1):  
   - Define `Ship` and `Asteroid` components with Transform and Velocity.  
   - Use Bevy's `SpriteBundle` for basic rendering.  

2. **Input Handling** (Day 2):  
   - Map `WASD`/`Arrow Keys` to ship rotation and thrust.  
   - Apply torque to `Ship`'s rotation component.  

3. **Physics Simulation** (Day 3):  
   - Implement velocity-based movement with `Transform::translation`.  
   - Add screen wrapping via `mod` operations on position.  

4. **Collision Detection** (Day 4):  
   - Use AABB checks between `Ship` and `Asteroid` components.  
   - Destroy colliding entities and trigger explosion effects.  

5. **Missile System** (Day 5):  
   - Spawn `Missile` entities on spacebar press.  
   - Apply velocity to missiles; destroy after lifetime.  

6. **Asteroid Spawning** (Day 6):  
   - Generate 5–10 asteroids with random positions/speeds.  
   - Add splitting logic: destroy large asteroids, spawn smaller ones on collision.  

7. **Optimization & Refinement** (Day 7+):  
   - Pool entities for performance (e.g., reuse missiles).  
   - Add score tracking and game-over states.  

**Rationale**: Start with minimal physics and input to validate core mechanics. Introduce complexity (e.g., splitting asteroids) only after foundational systems are stable. Prioritize Bevy's built-in systems (e.g., `Transform`) over custom math for maintainability. [end of text]


