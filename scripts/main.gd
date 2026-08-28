extends Node2D

@onready var character: Node = $Character

var movie_title_label: Label
var action_label: Label
var timer_label: Label
var reveal_button: Button

var secret_movie: Dictionary
var movie_actions: Array
var sequence_index := 0
var action_elapsed := 0.0
var time_left := 15.0
var round_running := false

func _ready() -> void:
	create_interface()
	start_round()

func _process(delta: float) -> void:
	if not round_running:
		return

	time_left -= delta
	action_elapsed += delta

	timer_label.text = "Time: " + str(ceil(time_left))

	if action_elapsed >= 2.5:
		action_elapsed = 0.0
		sequence_index += 1

		if sequence_index >= movie_actions.size():
			sequence_index = 0

		character.call("play_action", movie_actions[sequence_index])

	if time_left <= 0.0:
		round_running = false
		timer_label.text = "Time's up!"
		action_label.text = "Click Reveal Answer"
		reveal_button.disabled = false

func _draw() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, get_viewport_rect().size),
		Color("#202938")
	)

func create_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var panel := VBoxContainer.new()
	panel.position = Vector2(32, 28)
	panel.add_theme_constant_override("separation", 10)
	layer.add_child(panel)

	var title := Label.new()
	title.text = "Dumb Charades"
	title.add_theme_font_size_override("font_size", 30)
	panel.add_child(title)

	movie_title_label = Label.new()
	movie_title_label.text = "Movie: ???"
	movie_title_label.add_theme_font_size_override("font_size", 22)
	panel.add_child(movie_title_label)

	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 20)
	panel.add_child(timer_label)

	action_label = Label.new()
	action_label.text = "Watch carefully!"
	action_label.add_theme_font_size_override("font_size", 20)
	panel.add_child(action_label)

	var round_buttons := HBoxContainer.new()
	round_buttons.add_theme_constant_override("separation", 8)
	panel.add_child(round_buttons)

	var start_button := Button.new()
	start_button.text = "Start Round"
	start_button.custom_minimum_size = Vector2(130, 42)
	start_button.pressed.connect(start_round)
	round_buttons.add_child(start_button)

	reveal_button = Button.new()
	reveal_button.text = "Reveal Answer"
	reveal_button.custom_minimum_size = Vector2(130, 42)
	reveal_button.pressed.connect(reveal_answer)
	round_buttons.add_child(reveal_button)

	var test_label := Label.new()
	test_label.text = "Testing actions:"
	panel.add_child(test_label)

	var test_buttons := HBoxContainer.new()
	test_buttons.add_theme_constant_override("separation", 8)
	panel.add_child(test_buttons)

	add_action_button(test_buttons, "Idle", "idle")
	add_action_button(test_buttons, "Wave", "wave")
	add_action_button(test_buttons, "Point", "point")
	add_action_button(test_buttons, "Clap", "clap")
	add_action_button(test_buttons, "Think", "think")

func add_action_button(
	container: HBoxContainer,
	button_text: String,
	action: String
) -> void:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(90, 42)
	button.pressed.connect(test_action.bind(action))
	container.add_child(button)

func start_round() -> void:
	secret_movie = MovieDeck.random_movie()
	movie_actions = secret_movie["actions"]
	sequence_index = 0
	action_elapsed = 0.0
	time_left = 15.0
	round_running = true

	movie_title_label.text = "Movie: ???"
	action_label.text = "Watch the action sequence!"
	reveal_button.disabled = true

	character.call("play_action", movie_actions[sequence_index])

func reveal_answer() -> void:
	movie_title_label.text = "Movie: " + secret_movie["title"]
	action_label.text = "Answer revealed!"

func test_action(action: String) -> void:
	round_running = false
	reveal_button.disabled = false
	action_label.text = "Testing: " + action.capitalize()
	character.call("play_action", action)
