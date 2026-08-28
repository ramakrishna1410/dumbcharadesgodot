extends Node2D

var current_action := "idle"
var action_time := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	action_time += delta
	queue_redraw()

func play_action(action: String) -> void:
	current_action = action
	action_time = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: play_action("idle")
			KEY_2: play_action("wave")
			KEY_3: play_action("point")
			KEY_4: play_action("clap")
			KEY_5: play_action("think")
			KEY_6: play_action("shoot_web")
			KEY_7: play_action("climb")
			KEY_8: play_action("roar")
			KEY_9: play_action("cast_spell")
			KEY_0: play_action("box")

func _draw() -> void:
	var skin := Color("#f4c7a1")
	var shirt := Color("#4f8cff")
	var outline := Color("#20242c")
	var animation := sin(action_time * 7.0)

	var head := Vector2(0, -115)
	var left_shoulder := Vector2(-28, -70)
	var right_shoulder := Vector2(28, -70)
	var left_hand := Vector2(-70, -20)
	var right_hand := Vector2(70, -20)

	match current_action:
		"wave":
			right_hand = Vector2(62, -118 + animation * 18)
		"shoot_web":
			right_hand = Vector2(125, -105)
			left_hand = Vector2(-20, -95)

		"climb":
			left_hand = Vector2(-58, -125 + animation * 15)
			right_hand = Vector2(58, -90 - animation * 15)

		"roar":
			left_hand = Vector2(-55, -45)
			right_hand = Vector2(55, -45)

		"cast_spell":
			right_hand = Vector2(120, -105)
			left_hand = Vector2(-18, -85)

		"box":
			right_hand = Vector2(75, -72 + animation * 18)
			left_hand = Vector2(-75, -72 - animation * 18)
		"point":
			# Point clearly toward the right side of the screen.
			right_hand = Vector2(135, -70)

		"clap":
			# Hands move apart and together repeatedly.
			var hand_distance: float = 16.0 + absf(sin(action_time * 10.0)) * 55.0
			left_hand = Vector2(-hand_distance, -42)
			right_hand = Vector2(hand_distance, -42)

		"think":
			# Hand rests near the chin, rather than above the head.
			right_hand = Vector2(18, -92)

	# Head and body
	draw_circle(head, 28, skin)
	draw_line(Vector2(0, -85), Vector2(0, 35), shirt, 48)
	draw_line(Vector2(0, 35), Vector2(-34, 110), outline, 14)
	draw_line(Vector2(0, 35), Vector2(34, 110), outline, 14)

	# Arms
	draw_line(left_shoulder, left_hand, outline, 16)
	draw_line(right_shoulder, right_hand, outline, 16)
	draw_circle(left_hand, 10, skin)
	draw_circle(right_hand, 10, skin)

	# Face
	draw_circle(Vector2(-10, -120), 3, outline)
	draw_circle(Vector2(10, -120), 3, outline)
	draw_arc(Vector2(0, -108), 11, 0.2, 2.9, 16, outline, 2)
	draw_arc(Vector2(0, -108), 11, 0.2, 2.9, 16, outline, 2)
	
		# Extra visual clue effects
	if current_action == "shoot_web":
		var web_color := Color("#d9f3ff")
		draw_line(Vector2(125, -105), Vector2(175, -135), web_color, 3)
		draw_line(Vector2(125, -105), Vector2(175, -105), web_color, 3)
		draw_line(Vector2(125, -105), Vector2(165, -80), web_color, 3)

	if current_action == "cast_spell":
		var magic_color := Color("#b978ff")
		draw_circle(Vector2(145, -115), 10, magic_color, false, 3)
		draw_line(Vector2(145, -140), Vector2(145, -155), magic_color, 3)
		draw_line(Vector2(120, -115), Vector2(105, -115), magic_color, 3)
		draw_line(Vector2(165, -115), Vector2(180, -115), magic_color, 3)

	if current_action == "roar":
		draw_circle(Vector2(0, -106), 9, Color("#1b1d24"))

	if current_action == "box":
		draw_circle(right_hand, 14, Color("#e85d5d"))
		draw_circle(left_hand, 14, Color("#e85d5d"))

	if current_action == "celebrate":
		var celebration_color := Color("#ffd166")
		draw_circle(Vector2(-75, -145), 5, celebration_color)
		draw_circle(Vector2(75, -145), 5, celebration_color)
		draw_circle(Vector2(0, -170), 5, celebration_color)
