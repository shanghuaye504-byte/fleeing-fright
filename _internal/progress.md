# Progress

## 2026-10-23 — baseline and scope

- GitHub connector profile and network-enabled gh api user both resolve shanghuaye504-byte.
- User authorizes creation and publication of a public GitHub repository with a descriptive name.
- User explicitly authorizes reconciling original paths/state against files on disk.
- Source backup: /private/tmp/fleeing-fright-original-20261023.tar.gz (outside repository).
- Baseline import completes with case warnings for BTM materials and RPG textures.
- Sandbox prevents Godot user-data/editor-settings writes; subsequent engine validation needs
  network-independent elevated local execution or an isolated portable engine configuration.
- No existing project AGENTS.md, README, or _internal documentation found.

## 2026-10-23 — implementation and validation

- Added shared Chinese menus, level catalog, guarded session state, HUD, pause/restart/navigation,
  mute, delta-based coin visuals, quiet looping ambience, icon, and bounded bubble/trail lifetime.
- Preserved original level geometry, movement tuning and collision layers. Added independent
  MoonGarden bonus level with explicit floor/wall collisions, 10 coins, two ghosts and non-colliding lamps.
- Corrected menu paths/third-level access, invalid ghost node lookups, enemy catch guards,
  ghost initialization ordering, player validity guards, and blocked slime patrol loop.
- Normalized three texture directory names in both disk and Git index; literal res:// reference
  audit finds no missing paths. Case-only renames require explicit staged git moves on macOS.
- User authorized supplying missing FBX texture or publishing if reliable recovery is unavailable.
  Added byte-identical bundled Albedo.png palette at legacy PolyartMaster01.png path; SHA-256 equality verified.
- Fresh final source import completes. Three pre-existing raw FBX external texture references
  remain unresolved (Texture_BaseColor_v02.png, texture_block_stone0.png, knight_diffuse.png),
  plus a legacy Ogg comment warning. Active scene materials override these; no FBX binary edits.
  These limitations are documented rather than asserting a completely error-free original asset import.
- Source regression: 64 checks, 0 failures, using Godot 4.7.1 headless on a clean imported copy.
- Bonus route: PASS, all 10 coins collected through actual movement inputs without teleporting;
  enemies stationary and avoided. This checks reachability, not complete dynamic difficulty balance.
- Exported Desktop PCK successfully without native executable templates; final PCK regression:
  64 checks, 0 failures, running from the exported pack outside the source directory.
- Final screenshots captured from Metal/Forward+ viewport; cover is separately labeled promotional art.
- No matching native executable export templates are installed. Release includes PCK and GitHub
  source archives; no standalone executable or cross-platform native validation is claimed.
- No suitable writing-style retrieval tools were available; README follows explicit Chinese/plain-language preferences.


## 2026-10-23 — user steering: invisible ghosts and camera

- User clarifies that undetected ghosts must be fully invisible and only bubble hits reveal them.
  Hide the whole visual subtree (including shadows), initialize transparency at 1.0, reveal over
  0.45s on bubble hit, and remove reveal-on-capture. Collision and hidden stationary behavior remain.
- Added a fixed-angle oblique orthographic camera, closer zoom, XZ follow with dead zone and
  exponential smoothing. Jump height does not affect focus height. V/HUD toggles a coin-bounds
  overview without using hidden enemy positions. No movement or collision geometry changes.
- Initial new camera tests caught that runtime script attachment needed explicit set_process(true).
  Corrected this and reran the suite: 87 checks, 0 failures. Bonus actual-input walk still passes.
- README and actual viewport screenshots updated to show invisible ghosts and both camera modes.
- Previous 64-check PCK is superseded and must be rebuilt/retested before publication.

## 2026-10-23 — final release validation

- Rebuilt the PCK after the invisible-ghost/camera steering. Direct exported-pack regression:
  87 checks, 0 failures, no runtime error output. Export completes with no error output.
- Actual Metal viewport captures include both close follow and overview modes; undetected ghost
  models and shadows are absent. Capture utility now stops the last scene before exit without leaks.
- Final bonus movement walk: PASS. Final documentation links, internal index, and whitespace checks pass.
- Release artifact: FleeingFright.pck, 44,644,780 bytes. SHA256SUMS.txt accompanies the download.
- Public repository target: shanghuaye504-byte/fleeing-fright; first release tag v0.1.0.

## 2026-10-23 — repository publication

- Created the requested public GitHub repository: https://github.com/shanghuaye504-byte/fleeing-fright.
- Pushed baseline and validated upgrade to main; local working tree was clean after push.
- Kept all original assets, including a 51.14 MiB FBX; GitHub accepts it with a size recommendation warning.
- Canonicalized the companion Unity folder metadata filename materials.meta with its asset directory.
  This does not change Godot runtime resources or the already verified PCK.

## 2026-10-23 — release completed

- Published https://github.com/shanghuaye504-byte/fleeing-fright/releases/tag/v0.1.0.
- Independent GitHub API read confirms draft=false, prerelease=false, and both assets uploaded.
- Server PCK size: 44,644,780 bytes; server digest matches local:
  28b5644a0bc8f3959f55655e01375a082512ef19cf5fd25f745a028b87ee3a3c.
- Local copies are in ignored build/FleeingFright.pck and build/SHA256SUMS.txt.
- Release tag points to the validated code; this final record is a documentation-only follow-up.
