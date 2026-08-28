# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A Godot 4.7 ("Mobile" rendering method, Jolt physics) game called "Dumb Charades" — a movie-charades game where a 3D character silently acts out a sequence of movie-related actions (shoot, jump, drive, roll, ...) and the player types/guesses the movie title before time runs out.

There is no build system, package manager, or test suite — this is a Godot editor project. There are no `.gd.uid`/`.import` files to hand-edit; they are Godot-generated metadata and should not be manually created or fixed up.

## Running the project

Open and run through the Godot 4.7 editor (or `godot4 --path .` from the CLI if the Godot binary is on PATH). The main scene is `scenes/main_3d_ual.tscn` (set via `run/main_scene` in `project.godot`), which uses `scripts/main_3d.gd` as its root script.

There are no automated tests, linters, or build commands in this repo.

## Architecture

### Scene/script duplication — know which one is live

The repo contains **two parallel generations** of the same gameplay idea; only one is wired up as the runnable game:

- **Live / current**: `scenes/main_3d_ual.tscn` + `scripts/main_3d.gd`. 3D, uses the "Universal Animation Library" (`assets/animations/UAL1_Standard.glb`) attached directly under a node named `Blake`, drives `$Blake/AnimationPlayer`, has a score counter and a text-input answer field (guess-by-typing).
- **Earlier iterations, not the main scene**:
  - `scenes/main.tscn` + `scripts/main.gd` + `scripts/character.gd` — a fully 2D prototype where the "character" is hand-drawn via `_draw()`/`draw_line`/`draw_circle` stick-figure code (no 3D model at all). Action set here (`wave`, `point`, `clap`, `think`, `shoot_web`, `climb`, `roar`, `cast_spell`, `box`, `celebrate`) is unrelated to the 3D action vocabulary.
  - `scenes/main_3d.tscn` — a 3D variant that composes `scenes/blake_3d.tscn` (a thin wrapper around `assets/characters/Blake.glb`) plus the UAL animation library as a sibling, rather than the flattened `main_3d_ual.tscn` layout.
  - `scenes/character_3d_test.tscn` + `scripts/character_3d_test.gd` — a standalone keyboard-driven animation tester (keys 1–8 trigger `idle`/`walk`/`run`/`jump`/`box`/`lock_hands`/`aim`/`shoot` via its own smaller `action_clips` map). Useful as a reference for wiring a new action to a UAL clip, but not part of the game loop.

When asked to change "the game," confirm whether the request is about the live 3D flow (`main_3d.gd`) or one of the earlier prototypes — they are not kept in sync and changes to one won't appear in the other.

### Action → animation clip mapping

Each `main*.gd` script keeps its own `action_name -> clip_name` dictionary (e.g. `clip_map` in `main_3d.gd`, `action_clips` in `character_3d_test.gd`) and calls `AnimationPlayer.play(clip_name)`, falling back to `"Idle"`/`"idle"` if the action isn't in the map. Adding a new charades action means: add the action string to the relevant movie's `actions` array in `MovieDeck`, then add a matching entry in that script's clip map pointing at a real clip name inside the AnimationPlayer (clip names come from the imported `UAL1_Standard.glb` / `Blake.glb`, browsable via the Godot AnimationPlayer panel or the online Animation Viewer linked in `assets/Universal Animation Library[Standard]/README.txt`).

### Movie/action data

`scripts/movie_deck.gd` defines `class_name MovieDeck` (a global script class, not an autoload/singleton) with a static `MOVIES` array of `{title, actions}` dictionaries and `MovieDeck.random_movie()`. This is the single source of truth for which movies exist and what action sequence represents each one. It's referenced directly as `MovieDeck.random_movie()` from `main.gd`/`main_3d.gd` without needing a `preload`/`load` — Godot resolves it via the global class name.

### Round flow (`main_3d.gd`)

`start_round()` picks a random movie, resets timer/score UI, and plays `"idle"`. After a short `intro_time` delay, the first action in the sequence plays. `_on_animation_finished` (connected to `AnimationPlayer.animation_finished`) advances `sequence_index` and loops the action sequence for as long as the round is running, ignoring the `"Idle"` clip's own finish signal so it doesn't get treated as an advance. The round ends when `time_left` hits 0; the player types a guess into `answer_input` and `submit_answer()` compares it case-insensitively against `secret_movie["title"]`. `reveal_answer()` short-circuits the round and shows the answer.

The 2D prototype (`main.gd`) instead advances the action sequence on a fixed 2.5s timer inside `_process`, since its hand-drawn character has no `AnimationPlayer`/`animation_finished` signal to hook into.
