extends Node


		
var formatted_output = ""

var curret_output = "":
	set(value):
		curret_output = value
		formatted_output = get_formatted_text_to_show()

func get_formatted_text_to_show():
	return ("[code]Ouptut:\n" + 
				curret_output + 
			"[/code]")



var levels = [
	"""
say 1
say 2
exit
say 3
""".strip_edges(),
"""
say 5
say 6
exit
say 7
""".strip_edges(),
]

var deleting_data = [
	[
		"  D",
		"     <"
	]
]
var current_deleting_data = deleting_data[current_level]

var current_level_data = levels[current_level]

var lines_to_remove_from = []
##returns spots that just got deleted
#func remove_space_from_deleting_data_beginning():
#	for i in range(deleting_data[current_level].size()):
#		if deleting_data[current_level].length() > 1:
#			deleting_data[current_level] = deleting_data[current_level].substr(1)
#			if deleting_data[current_level].length() == 0:
#				lines_to_remove_from.append(i)

var current_level: int = 0:
	set(value):
		current_level = value
		current_level_data = levels[current_level]
		current_deleting_data = deleting_data[current_level]

func get_current_level_data():
	return levels[current_level]
	
func _ready():
	formatted_output = get_formatted_text_to_show()

func restart_current_level():
	get_tree().reload_current_scene()
