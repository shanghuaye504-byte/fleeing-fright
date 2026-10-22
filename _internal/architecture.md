# Architecture

## Original runtime (2026-10-23 audit)

- Godot project declares 4.5 / Forward Plus. Available local validation engine: 4.7.1.
- Original entry is scenes/levels/Level0.tscn (via UID). Menus live in scenes/menus/.
- Active player: assets/models/player/character1.tscn + character_1.gd. Cardinal movement,
  grid center snapping, gravity, jump via ui_accept, bubble reveal via J.
- Active levels: scenes/levels/Level0.tscn, Level1.tscn, Level2.tscn; coin counts 8/14/14.
- Ghosts start hidden and stationary, become visible and chase after bubble impact.
  Slimes patrol horizontally; shark greedily follows the player on its current height.
- Existing core/, gameplay/, presentation/, world/ scripts are inactive placeholders.
- Original coin accounting uses three hard-coded Global counters. Existing collection can
  count repeated body-entered callbacks before delayed deletion.
- Original ghost scene has SeparetionArea but script requests SeparationArea.
- Level selection has a Level_0.tscn typo and no third-button connection.

## Change boundaries

Preserve original levels, player movement tuning, collision layers and enemy movement algorithms.
Add presentation and bounded guards; unify session accounting so restarts and results are deterministic.
New bonus content must reuse existing actors and remain independent of original geometry.
External assets are bundled; only some have included license evidence. Do not assert a blanket
license for the complete game. Keep bundled license files and document provenance limits.
