extends RefCounted
class_name MovieDeck

const MOVIES = [
	{
		"title": "Rocky",
		"actions": ["attack", "attack_jab", "attack", "jump_start", "jump", "jump_landing"]
	},
	{
		"title": "The Matrix",
		"actions": ["aim", "shoot", "roll", "jump_start", "jump", "jump_landing"]
	},
	{
		"title": "Mad Max: Fury Road",
		"actions": ["drive", "shoot", "attack", "run"]
	},
	{
		"title": "Mission: Impossible",
		"actions": ["drive", "aim", "shoot", "roll"]
	}
]

static func random_movie() -> Dictionary:
	return MOVIES.pick_random()
