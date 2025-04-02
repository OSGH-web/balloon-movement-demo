# Balloon Game Movement Demo
- built for godot 4.4
- barebones movement demo for dragon/balloon game
- use arrow keys to move

## Gameplay Demo
  <img src="./docs/output.gif" width="384">

- physics are controlled by the following variables (`./scripts/player.gd`)
```gdscript
# ./scripts/player.gd
const GRAVITY = 120
const FRICTION = -3
const PLAYER_Y_FORCE = 300
const PLAYER_X_FORCE = 180
```
- the player's Y force must be larger than gravity to get off the ground
- Y force is larger than X force because otherwise horizontal movement is harder to control.
- friction slows the player down while sliding on the ground

## Player Sprite Sheet
<img src="./assets/sprites/spelunky_testing_sprite_fire.png" width="384">

- located in `./assets/sprites/spelunky_testing_sprite_fire.png`

## Updates

### Added window scrolling
<img src="./docs/scroll.gif" width="384">

### Added fuel + power up (fuel replenishment**
<img src="./docs/fuel.gif" width="384">

### Added level select screen
<img src="./docs/level-select.jpg" width="384">

- auto-populates based on the contents of `./levels`

### Added gameplay loop/post-death options
<img src="./docs/end-of-level-options.jpg" width="384">

- if a player navigates to the "end zone" (red square in the bottom right), they beat the level and return to the level select screen
- if a player runs out of fuel, they can press A to replay the level, or Q to return to the level select screej

