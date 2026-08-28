extends RefCounted
class_name MovieDeck

const MOVIES = [
	{
		"title": "Rocky",
		"category": "Boxing Drama",
		"hints": ["Released in 1976, it won the Oscar for Best Picture.", "The hero trains by punching sides of beef and running up museum steps."],
		"actions": ["attack_jab", "attack", "attack_jab", "attack", "run", "jump_start", "jump", "jump_landing"]
	},
	{
		"title": "The Matrix",
		"category": "Sci-Fi Action",
		"hints": ["A 1999 film about a simulated reality called the Matrix.", "The hero dodges bullets in slow motion after taking a red pill."],
		"actions": ["aim", "shoot", "roll", "aim", "roll", "shoot"]
	},
	{
		"title": "Mad Max: Fury Road",
		"category": "Post-Apocalyptic Action",
		"hints": ["A 2015 film set in a desert wasteland after civilization's collapse.", "Most of the movie is one long car chase across the desert."],
		"actions": ["drive", "run", "attack", "drive", "shoot", "run"]
	},
	{
		"title": "Mission: Impossible",
		"category": "Spy Action",
		"hints": ["Based on a 1960s TV series about a secret agent team.", "The hero relies on gadgets and disguises to complete impossible missions."],
		"actions": ["drive", "aim", "shoot", "reload", "aim", "shoot"]
	}
]

static func random_movie(exclude_title: String = "") -> Dictionary:
	var candidates := MOVIES

	if exclude_title != "":
		candidates = MOVIES.filter(func(movie): return movie["title"] != exclude_title)

	return candidates.pick_random()
