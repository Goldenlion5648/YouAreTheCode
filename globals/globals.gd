extends Node


var formatted_output = ""
var should_play_reset_sound = false
var game_done = false

var curret_output = "":
	set(value):
		curret_output = value
		formatted_output = get_formatted_text_to_show()

func get_formatted_text_to_show():
	return ("[code]Output: " + curret_output + 
			"[/code]")

var registers = {}

var levels = [
	"""
output 1
output 2
output 3
""".strip_edges(),
"""
output 5
output 7
output 9
output 6
""".strip_edges(),
"""
output 0
output 0
output 53
output 5
""".strip_edges(),
"""
output 0
goto 5
output 867
output 5
output 9
""".strip_edges(),
"""
goto 3
goto 4
goto 2
output 9
""".strip_edges(),
"""
store $a = 5
output 3
output $a
""".strip_edges(),
"""
store $a = $a + 5
output 21
output $a
""".strip_edges(),
"""
store $a = 5
output 0
output $b
store $b = $a + 7
output $a
""".strip_edges(),
"""
store $b = 6
store $ab = 2
output $ab
store $b = $ab
output $b
""".strip_edges()
]

var level_goals = [
	"123",
	"967",
	"535",
	"9867",
	"9999",
	"355",
	"152",
	"0712",
	"2606",
]

var deleting_data = [
	[
		"<"
	],
	[
		"-<",
		"",
		"",
		"----<"
	],
	[
		"",
		"",
		"---<",
		"-<"
	],
	[
		"",
		"",
		"",
		"",
		"-<",
	],
	[
		"",
		"",
		"",
		"<",
	],
	[
		"-<",
		"",
		"",
	],
	[
		"",
		"--<",
		"",
	],
	[
		"",
		"<",
		"",
		"",
		"",
	],
	[
		"",
		"",
		"",
		"----<",
		"",
	]
]

var current_deleting_data = deleting_data[current_level].duplicate(true)
var current_level_data = levels[current_level]
var current_level_goal = level_goals[current_level]

var lines_to_remove_from = []
##returns spots that just got deleted
#func remove_space_from_deleting_data_beginning():
#	for i in range(deleting_data[current_level].size()):
#		if deleting_data[current_level].length() > 1:
#			deleting_data[current_level] = deleting_data[current_level].substr(1)
#			if deleting_data[current_level].length() == 0:
#				lines_to_remove_from.append(i)
func add_code_tag_to_string(to_edit) -> String:
	return ("[code]" + to_edit +"[/code]")


#var current_level: int = deleting_data.size() - 1:
var current_level: int = 0:
	set(value):
		var temp = current_level
		current_level = value
		if current_level >= levels.size():
			game_done = true
			print("changing scene")
#			current_level = temp
#			get_tree().change_scene_to_file("res://objects/end_scene.tscn")
		else:
			current_level_data = levels[current_level]
			current_deleting_data = deleting_data[current_level].duplicate(true)
			current_level_goal = level_goals[current_level]

func get_current_level_data():
	return levels[current_level]
	
#var previous_level = -1
func _ready():
	formatted_output = get_formatted_text_to_show()
	current_level = current_level + 0

func restart_current_level():
	current_level = current_level + 0
	curret_output = ""
	registers = {}
	get_tree().reload_current_scene()

func add_format_tag_to(tag: String, string: String):
	return "[{tag}]{string}[/{tag}]".format({"tag": tag, "string": string})
