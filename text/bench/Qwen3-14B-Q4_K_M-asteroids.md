[33m[0m No markdown in the reasoning.

## Output:
* Markdown with section headers.
* No markdown in the reasoning.
* Only the plan in markdown.

Okay, let's tackle this. The user wants a development plan for implementing the classic Asteroids game in Bevy. First, I need to break down the game into manageable tasks. Let's start with the bird's-eye view. Asteroids has a spaceship, asteroids, bullets, collisions, and scoring. Bevy is a game engine in Rust, so I should consider its ECS (Entity-Component-System) architecture.

The contract should outline the scope. The main features are movement, shooting, asteroid splitting, collisions, and scoring. But the user wants to focus on economy of complexity, so I need to prioritize core mechanics first. Maybe start with the spaceship movement and basic rendering.

For architecture, Bevy uses systems, components, and resources. The spaceship will have components like position, rotation, and velocity. Movement system will handle input and update position. Asteroids will be entities with their own components. Collision detection between bullets and asteroids, and between the ship and asteroids.

Task breakdown for the first alpha: set up Bevy project, create spaceship with movement, implement shooting, create asteroid spawning, handle collisions, and scoring. Each task needs to be justified. For example, starting with rendering the ship ensures the basic setup is correct. Then adding movement with WASD and rotation. Shooting bullets requires handling input and creating bullet entities.

Integration tests would check if the ship moves correctly, bullets are fired, asteroids spawn and collide. But how to test collisions? Maybe using a simple system that checks distance between entities. Also, need to manage resources like score and game state.

I should make sure each step builds on the previous one. Start with the basics, then add complexity. Justify each decision, like why using ECS for components and systems. Also, consider dependencies: Bevy's math libraries for vectors, and the asset loader for textures.

Potential risks: collision detection might be tricky, especially with rotating asteroids. But for the first alpha, maybe use bounding circles for simplicity. Also, performance with many asteroids, but initial implementation can handle that, and optimize later.

Okay, structuring all this into sections with headers. Make sure each part is concise, adds value, and follows the constraints.
## Bird's-eye Overview

Asteroids (1979) is a 2D arcade game with a spaceship, asteroids, bullets, and collisions. The core mechanics involve movement, shooting, asteroid destruction, and scoring. Bevy's ECS architecture enables efficient management of entities (spaceship, bullets, asteroids) and systems (physics, rendering, collision detection). The implementation will prioritize simplicity, leveraging Bevy's built-in systems for input, rendering, and math operations.

## Contract

**Scope**: Implement a minimal viable version of Asteroids with:
- Spaceship movement (rotation, thrust)
- Bullet firing
- Asteroid spawning and destruction
- Collision detection (ship/asteroid, bullet/asteroid)
- Score tracking

**Exclusions**:
- Multiplayer
- Sound effects
- Advanced graphics (e.g., sprite rotation)

**Rationale**: Focus on core mechanics to minimize complexity, ensuring a functional proof of concept before expanding.

## Architecture

**Entities**:
- `Spaceship`: Position, rotation, velocity, thrust state
- `Bullet`: Position, velocity, lifetime
- `Asteroid`: Position, rotation, velocity, size (for splitting)

**Components**:
- `Transform`: Position and rotation (Bevy's built-in)
- `Velocity`: Linear velocity vector
- `Thrust`: Boolean for engine state
- `Score`: Resource for tracking points

**Systems**:
- `InputHandler`: Captures keyboard input (WASD, space)
- `MovementSystem`: Updates position based on velocity and rotation
- `BulletSystem`: Spawns bullets on input, applies velocity
- `AsteroidSpawner`: Periodically spawns asteroids with randomized properties
- `CollisionSystem`: Detects overlaps between entities (ship/asteroid, bullet/asteroid)
- `ScoreSystem`: Updates score on asteroid destruction

**Dependencies**:
- Bevy's `Transform`, `GlobalTransform`, and `math` modules for vector operations
- `Time` resource for delta time in physics calculations

## Task Breakdown (Alpha/POC)

1. **Project Setup**  
   - Initialize Bevy project with `cargo generate`  
   - Configure `main.rs` with basic app setup (window, camera)  
   - Add `Transform` and `Velocity` components to `Spaceship`  
   - Render `Spaceship` as a simple triangle or sprite  

2. **Spaceship Movement**  
   - Implement `InputHandler` to capture WASD input  
   - Update `Velocity` based on rotation and thrust (W)  
   - Apply velocity to `Transform` in `MovementSystem`  
   - Add wrapping logic for screen edges  

3. **Bullet Firing**  
   - Spawn `Bullet` entities on spacebar press  
   - Set bullet velocity relative to spaceship's direction  
   - Add `lifetime` component to despawn bullets after timeout  

4. **Asteroid Spawning**  
   - Create `Asteroid` entity with random position, rotation, velocity  
   - Use `AsteroidSpawner` system to spawn at intervals  
   - Apply physics to asteroids (velocity, rotation)  

5. **Collision Detection**  
   - Use distance checks between `Spaceship` and `Asteroid` (via `Transform`)  
   - Check bullet-asteroid collisions using distance and bullet lifetime  
   - On collision, destroy entities and update score  

6. **Score System**  
   - Track score as a `Resource`  
   - Increment score on asteroid destruction  
   - Display score on screen using Bevy's UI system  

## Integration Test

**Test Case**: Verify spaceship movement and bullet collision  
- **Setup**: Spawn spaceship at origin, asteroid at (100, 0)  
- **Action**: Press W to thrust, spacebar to fire bullet  
- **Expect**:  
  - Spaceship moves in direction of rotation  
  - Bullet travels in spaceship's direction  
  - Bullet collides with asteroid (distance < threshold)  
  - Asteroid despawns, score increments  

**Rationale**: Ensures core mechanics (movement, shooting, collision) function as expected, validating the minimal viable implementation. Complexities like asteroid splitting or advanced graphics are deferred to subsequent iterations.  

**Risk Mitigation**:  
- Use bounding circle collision (distance check) for simplicity  
- Limit asteroid count to avoid performance issues in early testing  
- Use `Time` resource for consistent physics updates across platforms. [end of text]


