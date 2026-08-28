extends Node3D

@onready var animation_player: AnimationPlayer = $Blake/AnimationPlayer

var movie_title_label: Label
var category_label: Label
var action_label: Label
var hint_label: Label
var hint_button: Button
var timer_label: Label
var score_label: Label
var answer_input: LineEdit
var reveal_button: Button

var secret_movie: Dictionary
var movie_actions: Array
var sequence_index := 0
var action_elapsed := 0.0
var time_left := 15.0
var intro_time := 0.0
var score := 0
var round_running := false
var round_answered := false
var hints_revealed := 0

var clip_map := {
	"idle": "Idle",
	"run": "Jog_Fwd",
	"jump_start": "Jump_Start",
	"jump": "Jump",
	"jump_landing": "Jump_Land",
	"attack": "Punch_Cross",
	"attack_jab": "Punch_Jab",
	"aim": "Pistol_Aim_Neutral",
	"shoot": "Pistol_Shoot",
	"reload": "Pistol_Reload",
	"roll": "Roll",
	"drive": "Driving",
	"dance": "Dance"
}

func _ready() -> void:
	create_interface()
	animation_player.animation_finished.connect(_on_animation_finished)
	start_round()

func _on_animation_finished(animation_name: StringName) -> void:
	if not round_running or intro_time > 0.0:
		return

	# Ignore the idle reset animation.
	if animation_name == "Idle":
		return

	sequence_index += 1

	if sequence_index >= movie_actions.size():
		sequence_index = 0

	play_action(str(movie_actions[sequence_index]))

func _process(delta: float) -> void:
	if not round_running:
		return

	if intro_time > 0.0:
		intro_time -= delta
		timer_label.text = "Get ready..."

		if intro_time <= 0.0:
			play_action(str(movie_actions[0]))

		return

	time_left -= delta
	timer_label.text = "Time: " + str(ceil(time_left))

	if time_left <= 0.0:
		round_running = false
		timer_label.text = "Time's up!"
		action_label.text = "Type your answer, then submit it."
		reveal_button.disabled = false
func create_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var panel := VBoxContainer.new()
	panel.position = Vector2(32, 28)
	panel.add_theme_constant_override("separation", 10)
	layer.add_child(panel)

	var title := Label.new()
	title.text = "Dumb Charades 3D"
	title.add_theme_font_size_override("font_size", 30)
	panel.add_child(title)

	score_label = Label.new()
	score_label.text = "Score: 0"
	panel.add_child(score_label)

	movie_title_label = Label.new()
	movie_title_label.text = "Movie: ???"
	movie_title_label.add_theme_font_size_override("font_size", 22)
	panel.add_child(movie_title_label)

	category_label = Label.new()
	panel.add_child(category_label)

	timer_label = Label.new()
	panel.add_child(timer_label)

	action_label = Label.new()
	action_label.text = "Watch carefully!"
	action_label.add_theme_font_size_override("font_size", 20)
	panel.add_child(action_label)

	hint_label = Label.new()
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint_label.custom_minimum_size = Vector2(320, 0)
	panel.add_child(hint_label)

	hint_button = Button.new()
	hint_button.text = "Get a Hint"
	hint_button.custom_minimum_size = Vector2(140, 42)
	hint_button.pressed.connect(reveal_hint)
	panel.add_child(hint_button)

	answer_input = LineEdit.new()
	answer_input.placeholder_text = "Type your movie answer"
	answer_input.custom_minimum_size = Vector2(320, 42)
	panel.add_child(answer_input)

	var submit_button := Button.new()
	submit_button.text = "Submit Answer"
	submit_button.custom_minimum_size = Vector2(170, 42)
	submit_button.pressed.connect(submit_answer)
	panel.add_child(submit_button)

	var start_button := Button.new()
	start_button.text = "Start Round"
	start_button.custom_minimum_size = Vector2(140, 42)
	start_button.pressed.connect(start_round)
	panel.add_child(start_button)

	reveal_button = Button.new()
	reveal_button.text = "Reveal Answer"
	reveal_button.custom_minimum_size = Vector2(140, 42)
	reveal_button.pressed.connect(reveal_answer)
	panel.add_child(reveal_button)

func start_round() -> void:
	var previous_title := str(secret_movie.get("title", ""))
	secret_movie = MovieDeck.random_movie(previous_title)
	movie_actions = secret_movie["actions"]

	sequence_index = 0
	action_elapsed = 0.0
	time_left = 15.0
	intro_time = 1.5
	round_running = true
	round_answered = false
	hints_revealed = 0

	movie_title_label.text = "Movie: ???"
	category_label.text = "Category: " + str(secret_movie["category"])
	action_label.text = "Watch carefully, then type the movie title!"
	hint_label.text = ""
	hint_button.disabled = false
	timer_label.text = "Get ready..."
	score_label.text = "Score: " + str(score)
	answer_input.clear()
	reveal_button.disabled = true

	# Always reset the character before the clue starts.
	play_action("idle")

func submit_answer() -> void:
	if round_running:
		action_label.text = "Wait until the round finishes."
		return

	if round_answered:
		return

	var player_answer := answer_input.text.strip_edges().to_lower()
	var correct_answer := str(secret_movie["title"]).to_lower()

	if player_answer == correct_answer:
		score += max(3 - hints_revealed, 1)
		round_answered = true
		action_label.text = "Correct!"
		movie_title_label.text = "Movie: " + str(secret_movie["title"])
		score_label.text = "Score: " + str(score)
	else:
		action_label.text = "Incorrect. Try again!"

func reveal_hint() -> void:
	var hints: Array = secret_movie["hints"]

	if hints_revealed >= hints.size():
		return

	hint_label.text += ("\n" if hint_label.text != "" else "") + str(hints[hints_revealed])
	hints_revealed += 1

	if hints_revealed >= hints.size():
		hint_button.disabled = true

func reveal_answer() -> void:
	round_running = false
	round_answered = true
	movie_title_label.text = "Movie: " + str(secret_movie["title"])
	action_label.text = "Answer revealed!"

func play_action(action_name: String) -> void:
	var clip_name: String = clip_map.get(action_name, "Idle")

	if animation_player.has_animation(clip_name):
		animation_player.play(clip_name)
