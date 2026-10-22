# Architecture

## Runtime

- Source originally declares Godot 4.5 / Forward Plus. Validation and packaged PCK use Godot 4.7.1.
- Entry: scenes/menus/main_menu.tscn. project.godot uses an explicit path rather than a cache-dependent UID.
- Global autoload owns the four-entry level catalog, session counters/time, run serial, audio mute,
  victory/defeat ownership, and navigation. run_active guards collection/death reentrancy.
- Navigation increments run_serial, invalidates delayed results, and clears SceneTree.paused.
- LevelAtmosphere is a child in each active level. Deferred start runs after level construction,
  counts actual coin nodes, creates GameHUD, non-colliding stars, and a quiet looping CC0 ambience.
- GameHUD processes while paused; world/player/enemies and elapsed time pause normally.
- Shared MenuScreen + VisualTheme implement main/level/result screens; original entry scripts remain wrappers.
- Active player: assets/models/player/character1.tscn + character_1.gd. Cardinal movement,
  grid snapping, gravity and jump tuning are preserved. J fires bounded-lifetime bubbles, minimum 0.22s apart.
- Coins rotate using delta, bob only their visual child, accept only players, hide immediately,
  count once and leave briefly for audio. Session completion uses actual coin count.
- Ghosts start completely invisible: the visual subtree is hidden, including shadows, and
  mesh transparency is 1.0. Only bubble impact calls self_reveal; capture alone never reveals.
  A detected ghost fades in over 0.45 seconds and starts chasing.
  Slimes patrol horizontally with a bounded two-direction check; shark greedily chases on its height.
  Enemy movement algorithms and collision layers are preserved. Catch handlers share Global's result guard.
- Spawned ghosts receive local spawn coordinates BEFORE add_child, so _ready initializes movement targets correctly.

## Levels

- Level0: 8 coins, original courtyard geometry.
- Level1: 14 coins, original two-height layout and horizontal patrols.
- Level2: 14 coins, original waterfront geometry and shark; original overlapping coin pair retained.
- MoonGarden: 10 coins, original actor assets, ring routes around two three-cell obstacles,
  two fixed ghosts, independent explicit floor/wall collision bodies and non-colliding lamps.
  New block meshes are decorative; physical support is provided by the explicit bodies.
- core/, gameplay/, unused presentation/ files and world/ contain original inactive scaffolding.
  They are retained for source history and must not be represented as active systems.

## Camera

- LevelAtmosphere attaches FollowCamera to the existing camera after scene construction.
- Orthographic oblique view has a fixed yaw/elevation. Default size is 10.5 world units,
  or 11.5 in the larger original levels. The camera follows XZ position using a 1.1-unit
  dead zone and delta-independent exponential smoothing. Focus height is fixed at 1.0
  to avoid jump bobbing; it does not alter character movement or collision transforms.
- V or the HUD view button toggles an overview calculated from the current level's original
  coin bounds and spawn. It never uses hidden enemies to frame the shot. Reset recreates
  the camera at the player's spawn; pausing freezes camera updates.
- Overview projection is checked against the unobstructed viewport for every level.

## Assets and exports

- Canonical folders: BTM_Items_Gems/materials and RPG Monster DUO PBR Polyart/textures.
  GhostCharacter_Free/textures is also normalized. Casing matches FBX importer references. Keep all textual references synchronized.
- Missing FBX palette is filled by a copy of bundled Albedo.png at FinalTextures/PolyartMaster01.png;
  see artwork.md for provenance. Existing scene materials are preserved. Raw source FBXs still contain three missing legacy
  texture references: Texture_BaseColor_v02.png (external author path), texture_block_stone0.png,
  and knight_diffuse.png. Active scene material overrides are intact; do not invent original textures.
- docs/ is ignored by Godot using .gdignore. Desktop PCK export excludes docs/, _internal/ and tests/.
- Desktop PCK preset packages the game without requiring native executable templates. The release
  pack requires a matching Godot runtime; it is not a standalone executable.
- tests/smoke.gd checks active scene transitions and physics; tests/walk_garden.gd walks the bonus
  level using actual input with enemies stationary; tests/capture.gd writes actual viewport PNGs.

## Change boundaries

Preserve original geometry, movement tuning and collision layers unless specifically validated.
Keep presentation separate from session state. Use only one delayed result owner; every navigation
must cancel previous results. New bonus routes must be validated through actual movement.
Keep third-party license files. No blanket license is asserted for assets lacking bundled license evidence.
