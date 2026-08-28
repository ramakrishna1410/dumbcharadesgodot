extends RefCounted
class_name MovieDeck

const MOVIES = [
	{
		"title": "Rocky",
		"hints": ["Category: Boxing Drama", "Released in 1976, it won the Oscar for Best Picture.", "The hero trains by punching sides of beef and running up museum steps."],
		"actions": ["attack_jab", "attack", "attack_jab", "attack", "run", "jump_start", "jump", "jump_landing"]
	},
	{
		"title": "The Matrix",
		"hints": ["Category: Sci-Fi Action", "A 1999 film about a simulated reality called the Matrix.", "The hero dodges bullets in slow motion after taking a red pill."],
		"actions": ["aim", "shoot", "roll", "aim", "roll", "shoot"]
	},
	{
		"title": "Mad Max: Fury Road",
		"hints": ["Category: Post-Apocalyptic Action", "A 2015 film set in a desert wasteland after civilization's collapse.", "Most of the movie is one long car chase across the desert."],
		"actions": ["drive", "run", "attack", "drive", "shoot", "run"]
	},
	{
		"title": "Mission: Impossible",
		"hints": ["Category: Spy Action", "Based on a 1960s TV series about a secret agent team.", "The hero relies on gadgets and disguises to complete impossible missions."],
		"actions": ["drive", "aim", "shoot", "reload", "aim", "shoot"]
	},
	{
		"title": "Speed",
		"hints": ["Category: Action Thriller", "A 1994 film where a city bus can't slow down below 50 mph.", "A cop must keep the speed up or a bomb on board will explode."],
		"actions": ["drive", "run", "jump_start", "jump", "jump_landing", "drive"]
	},
	{
		"title": "Saturday Night Fever",
		"hints": ["Category: Dance Drama", "A 1977 film starring John Travolta as a Brooklyn disco dancer.", "The hero dreams of winning a local dance contest."],
		"actions": ["dance", "dance", "run", "dance"]
	},
	{
		"title": "John Wick",
		"hints": ["Category: Assassin Action", "A 2014 film about a retired hitman pulled back for one last job.", "The story kicks off after the villains kill the hero's dog."],
		"actions": ["aim", "shoot", "reload", "roll", "attack", "shoot"]
	},
	{
		"title": "Home Alone",
		"hints": ["Category: Family Comedy", "A 1990 film about a boy accidentally left behind during Christmas.", "He booby-traps his house against two bumbling burglars."],
		"actions": ["run", "attack_jab", "roll", "jump_start", "jump", "jump_landing"]
	}
]

static func random_movie(exclude_title: String = "") -> Dictionary:
	var candidates := MOVIES

	if exclude_title != "":
		candidates = MOVIES.filter(func(movie): return movie["title"] != exclude_title)

	return candidates.pick_random()
