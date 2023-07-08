extends RichTextLabel

var text_to_show: String = ""

var player_current_line_number = 0
var player_pos_in_line = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	show_backspace_coming()
	self.text_to_show = Globals.get_current_level_data()
	print(zip_coming_characters(text_to_show))
	self.text = get_formatted_text_to_show()

func get_player_overall_pos():
	var player_overall_pos = 0
	var text_to_show_as_array = text_to_show.split("\n")
	var i = 0
	for line in text_to_show_as_array:
		if i == player_current_line_number:
			player_overall_pos += player_pos_in_line
			break
		#the + 1 is to account for the new line character
		player_overall_pos += line.length() + 1 
		i += 1
	return player_overall_pos

func remove_space_from_deleting_data_beginning():
	var text_to_show_lines = text_to_show.split("\n")
	for i in range(Globals.deleting_data[Globals.current_level].size()):
		if Globals.deleting_data[Globals.current_level][i].length() >= 1:
			var deleted_character = Globals.deleting_data[Globals.current_level][0]
			Globals.deleting_data[Globals.current_level][i] = Globals.deleting_data[Globals.current_level][i].substr(1)
			if Globals.deleting_data[Globals.current_level][i].length() == 0:
				#TODO: check if the character was supposed to delete the single character (current) or whole line
				text_to_show_lines[i] = text_to_show_lines[i].substr(0, text_to_show_lines[i].length() - 1)
	text_to_show = "\n".join(text_to_show_lines)
	

func zip_coming_characters(string_to_edit: String) -> String:
	var ret = ""
	var lines = string_to_edit.split("\n")
	for i in range(min(lines.size(), Globals.current_deleting_data.size())):
		ret += lines[i] + "[color=red]" + Globals.current_deleting_data[i] + "[/color]" + "\n"
	return ret

func get_formatted_text_to_show():
	var player_overall_pos = get_player_overall_pos()
	
	var player_pos_showing = (text_to_show.substr(0, player_overall_pos) +
				"[u][color=green]" + text_to_show.substr(player_overall_pos, 1) + "[/color][/u]" +
				text_to_show.substr(player_overall_pos + 1))
			
	var zipped = zip_coming_characters(player_pos_showing)
	var with_code_tag = add_code_tag_to_string(zipped)
	return with_code_tag

func add_code_tag_to_string(to_edit) -> String:
	return ("[code]" + to_edit +"[/code]")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()
	pass

func adjust_for_going_off_end_of_lines():
	var text_to_show_as_array = text_to_show.split("\n")
	if player_pos_in_line < 0 and player_current_line_number > 0:
		player_current_line_number -= 1
		player_pos_in_line = text_to_show_as_array[player_current_line_number].length() - 1
	
	if player_pos_in_line >= text_to_show_as_array[player_current_line_number].length() and\
	player_current_line_number + 1< text_to_show_as_array.size():
		player_current_line_number += 1
		player_pos_in_line = 0

func adjust_for_edge_cases():
	var text_to_show_as_array = text_to_show.split("\n")
	
	player_current_line_number = min(text_to_show_as_array.size() - 1, player_current_line_number)
	player_current_line_number = max(0, player_current_line_number)
	
	player_pos_in_line = min(text_to_show_as_array[player_current_line_number].length() - 1, player_pos_in_line)
	player_pos_in_line = max(0, player_pos_in_line)
	


	
func update_text_display():
	self.text = get_formatted_text_to_show()
#	print("current line is ", player_current_line_number)
#	print("current pos in line is ", player_pos_in_line)

func get_word_on_cursor():
	var player_overall_position = get_player_overall_pos()
	var left_space = max(text_to_show.rfind("\n", player_overall_position) + 1, 
						text_to_show.rfind(" ", player_overall_position) + 1, 0)
	var right_space = text_to_show.find(" ", player_overall_position)
	var new_line_spot = text_to_show.find("\n", player_overall_position)
	if right_space == -1 or (new_line_spot < right_space and new_line_spot != -1):
		right_space = new_line_spot
	if right_space == -1:
		right_space = text_to_show.length()
	
	
	print("left space is ", left_space)
	print("right space is ", right_space)
	var word_on_cursor = text_to_show.substr(left_space, right_space - left_space)
	return word_on_cursor

func check_level_advance():
	var word_on_cursor = get_word_on_cursor()
	print("word on cursor is ", word_on_cursor)
	if word_on_cursor.strip_edges() == "exit":
		print("level complete!")
		Globals.current_level += 1
		Globals.restart_current_level()



func run_current_line():
	var current_line_text = text_to_show.split("\n")[player_current_line_number]
	if current_line_text.begins_with("say"):
		var words_on_line = current_line_text.split(" ")
		if words_on_line.size() > 1:
			Globals.curret_output += words_on_line[1]
	
func show_backspace_coming():
	var test_string = """hi
	there
	buddy"""
	var backspace_regex = RegEx.new()
	backspace_regex.compile("(.+)\n")
	var replaced = backspace_regex.sub(test_string, "$1\n")
	print(replaced)
	print("a".repeat(6))
	

func check_input():
	var moved = false
	if Input.is_action_just_pressed("enter_word"):
		print("checking")
#		check_level_advance()
		run_current_line()
	if Input.is_action_just_pressed("reset"):
		Globals.restart_current_level()
	if Input.is_action_just_pressed("down"):
		player_current_line_number += 1
		moved = true
	elif Input.is_action_just_pressed("up"):
		player_current_line_number -= 1
		moved = true
	elif Input.is_action_just_pressed("left"):
		player_pos_in_line -= 1
		adjust_for_going_off_end_of_lines()
		moved = true
	elif Input.is_action_just_pressed("right"):
		player_pos_in_line += 1
		adjust_for_going_off_end_of_lines()
		moved = true
	
	if moved:
		adjust_for_edge_cases()
		update_text_display()
		print("word on cursor is ", get_word_on_cursor())

func _on_delete_from_end_timer_timeout():
#	text_to_show = text_to_show.substr(0, text_to_show.length() - 1)
	update_text_display()
	$deleteFromEndTimer.start()

func _on_move_in_deleting_characters_timeout():
	remove_space_from_deleting_data_beginning()
	update_text_display()
	$moveInDeletingCharacters.start()








