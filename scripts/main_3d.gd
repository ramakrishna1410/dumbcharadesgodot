extends Node3D

@onready var animation_player: AnimationPlayer = $Blake/AnimationPlayer

var movie_title_label: Label
var title_blanks_label: Label
var action_label: Label
var hint_label: Label
var hint_button: Button
var timer_label: Label
var score_label: Label
var answer_input: LineEdit
var reveal_button: Button

const ACTION_DURATION := 2.2
const ACTION_BLEND_TIME := 0.15
const MATCH_SIMILARITY_THRESHOLD := 0.9

# These clips must always play start-to-finish uninterrupted so the jump reaches
# its landing pose instead of getting cut off mid-air by ACTION_DURATION.
const UNCAPPED_ACTIONS := ["jump_start", "jump", "jump_landing"]

var secret_movie: Dictionary
var movie_actions: Array
var sequence_index := 0
var action_elapsed := 0.0
var current_action_name := "idle"
var time_left := 45.0
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

	advance_action()

func advance_action() -> void:
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

	# Cap how long any single clip (e.g. the long "Driving" clip) can hold the
	# clue, so the action sequence keeps cycling at a steady, repetitive pace.
	# The jump trio is exempt so it always plays through to a landed pose.
	action_elapsed += delta

	if action_elapsed >= ACTION_DURATION and not UNCAPPED_ACTIONS.has(current_action_name):
		advance_action()

	time_left -= delta
	timer_label.text = "Time: " + str(ceil(time_left))

	if time_left <= 0.0 and not round_answered:
		round_answered = true
		round_running = false
		timer_label.text = "Time's up!"
		movie_title_label.text = "Movie: " + str(secret_movie["title"])
		action_label.text = "Time's up! The answer was " + str(secret_movie["title"]) + "."
		reveal_button.disabled = true
		finish_round(2.5)
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

	title_blanks_label = Label.new()
	title_blanks_label.add_theme_font_size_override("font_size", 22)
	panel.add_child(title_blanks_label)

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
	time_left = 45.0
	intro_time = 1.5
	round_running = true
	round_answered = false
	hints_revealed = 0

	movie_title_label.text = "Movie: ???"
	title_blanks_label.text = build_title_blanks(str(secret_movie["title"]))
	action_label.text = "Watch carefully, then type the movie title!"
	hint_label.text = ""
	hint_button.disabled = false
	timer_label.text = "Get ready..."
	score_label.text = "Score: " + str(score)
	answer_input.clear()
	reveal_button.disabled = false

	# Always reset the character before the clue starts.
	play_action("idle")

func submit_answer() -> void:
	if round_answered:
		return

	var player_answer := normalize_for_match(answer_input.text)
	var correct_answer := normalize_for_match(str(secret_movie["title"]))
	var is_match := player_answer == correct_answer \
		or text_similarity(player_answer, correct_answer) >= MATCH_SIMILARITY_THRESHOLD

	if is_match:
		score += max(5 - hints_revealed, 1)
		round_answered = true
		round_running = false
		action_label.text = "Correct!"
		movie_title_label.text = "Movie: " + str(secret_movie["title"])
		score_label.text = "Score: " + str(score)
		reveal_button.disabled = true
		finish_round(2.0)
	else:
		action_label.text = "Incorrect. Try again!"

# Lowercases, strips punctuation that's hard to type correctly (e.g. the colon
# in "Mad Max: Fury Road"), and collapses whitespace so answers can be compared
# on their words alone.
func normalize_for_match(text: String) -> String:
	var normalized := text.strip_edges().to_lower()

	for punctuation_char in [":", ",", ".", "'", "-", "!", "?"]:
		normalized = normalized.replace(punctuation_char, "")

	while normalized.find("  ") != -1:
		normalized = normalized.replace("  ", " ")

	return normalized.strip_edges()

# Levenshtein-distance similarity ratio in [0, 1], used to forgive small typos.
func text_similarity(a: String, b: String) -> float:
	var len_a := a.length()
	var len_b := b.length()

	if len_a == 0 and len_b == 0:
		return 1.0

	if len_a == 0 or len_b == 0:
		return 0.0

	var previous_row: Array[int] = []
	previous_row.resize(len_b + 1)

	for j in range(len_b + 1):
		previous_row[j] = j

	for i in range(1, len_a + 1):
		var current_row: Array[int] = []
		current_row.resize(len_b + 1)
		current_row[0] = i

		for j in range(1, len_b + 1):
			var substitution_cost := 0 if a[i - 1] == b[j - 1] else 1
			current_row[j] = min(
				previous_row[j] + 1,
				current_row[j - 1] + 1,
				previous_row[j - 1] + substitution_cost
			)

		previous_row = current_row

	var distance: int = previous_row[len_b]
	return 1.0 - float(distance) / float(max(len_a, len_b))

# Waits, then starts the next round automatically.
func finish_round(delay_seconds: float) -> void:
	round_running = false
	await get_tree().create_timer(delay_seconds).timeout
	start_round()

func reveal_hint() -> void:
	var hints: Array = secret_movie["hints"]
	var total_hints := hints.size() + 1 # + the derived first-letters hint

	if hints_revealed >= total_hints:
		return

	var hint_text: String

	if hints_revealed < hints.size():
		hint_text = str(hints[hints_revealed])
	else:
		hint_text = "First letters: " + build_first_letters(str(secret_movie["title"]))

	hint_label.text += ("\n" if hint_label.text != "" else "") + hint_text
	hints_revealed += 1

	if hints_revealed >= total_hints:
		hint_button.disabled = true

# Replaces each letter with "_" while leaving spaces/punctuation as-is, e.g.
# "Mad Max: Fury Road" -> "___ ___: ____ ____". Shown for free so players get
# the word-count/word-length signal real charades gives up front.
func build_title_blanks(title: String) -> String:
	var blanks := ""

	for i in range(title.length()):
		var current_char := title[i]
		blanks += "_" if current_char.to_upper() != current_char.to_lower() else current_char

	return blanks

# Joins each word's first letter, e.g. "Mad Max: Fury Road" -> "M M F R".
func build_first_letters(title: String) -> String:
	var letters: Array[String] = []

	for word in title.split(" ", false):
		if word.length() > 0:
			letters.append(word[0].to_upper())

	return " ".join(letters)

func reveal_answer() -> void:
	if round_answered:
		return

	round_answered = true
	movie_title_label.text = "Movie: " + str(secret_movie["title"])
	action_label.text = "Answer revealed!"
	reveal_button.disabled = true
	finish_round(2.0)

func play_action(action_name: String) -> void:
	var clip_name: String = clip_map.get(action_name, "Idle")
	action_elapsed = 0.0
	current_action_name = action_name

	if animation_player.has_animation(clip_name):
		animation_player.play(clip_name, ACTION_BLEND_TIME)
