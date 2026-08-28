extends Node3D

@onready var animation_player: AnimationPlayer = $Blake/AnimationPlayer

var action_clips := {
	"idle": "idle",
	"walk": "walk",
	"run": "run",
	"jump": "jump_air",
	"box": "hand_attack",
	"lock_hands": "hand_lock",
	"aim": "mock_gun",
	"shoot": "gun_shot"
}

func _ready() -> void:
	play_action("idle")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: play_action("idle")
			KEY_2: play_action("walk")
			KEY_3: play_action("run")
			KEY_4: play_action("jump")
			KEY_5: play_action("box")
			KEY_6: play_action("lock_hands")
			KEY_7: play_action("aim")
			KEY_8: play_action("shoot")

func play_action(action_name: String) -> void:
	var clip: String = action_clips.get(action_name, "idle")

	if animation_player.has_animation(clip):
		animation_player.play(clip)
