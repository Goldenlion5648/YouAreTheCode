extends RichTextLabel

var text_to_show: String = ""

var player_current_line_number = 0
var player_pos_in_line = 2
var level_typed_progress = 0
var allowed_to_type = false
var cursor_on = true

var next_level_text = "submit"
var output_word = "output"

@onready var eat_letter_sound = $eatLetterSound
@onready var print_sound = $printSound
@onready var typing_sound = $typingSound
@onready var reset_sound = $resetSound
@onready var level_complete_sound = $levelCompleteSound
@onready var eat_nothing = $eatNothing
@onready var ding_sound = $registerWriteSound
@onready var jump_sound = $jumpSound
@onready var error_sound = $errorSound


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.game_done:
		Globals.game_done = false
		get_tree().change_scene_to_file("res://objects/end_scene.tscn")
		
		return
	if Globals.should_play_reset_sound:
		reset_sound.play()
		Globals.should_play_reset_sound = false
	if Globals.current_level == 0:
		level_complete_sound.play()
#	elif Globals.current_level != 0:
#		level_complete_sound.play()
	show_backspace_coming()
	self.text_to_show = Globals.get_current_level_data()
#	print(zip_coming_characters(text_to_show))
#TODO ADD THIS BACK IF NEEDED
#	self.text = get_formatted_text_to_show(text_to_show)
	

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
	for i in range(Globals.current_deleting_data.size()):
		if Globals.current_deleting_data[i].length() >= 1:
			var deleted_character = Globals.current_deleting_data[i][0] + ""
#			print("deleted character=", deleted_character)
			Globals.current_deleting_data[i] = Globals.current_deleting_data[i].substr(1)
			if Globals.current_deleting_data[i].length() == 0:
				#TODO: check if the character was supposed to delete the single character (current) or whole line
				if deleted_character == "<":
					text_to_show_lines[i] = text_to_show_lines[i].substr(0, text_to_show_lines[i].length() - 1)
					if text_to_show_lines[i].length() == 0:
						text_to_show_lines[i] = " "
				elif deleted_character == "«":
					text_to_show_lines[i] = " "
				
				eat_letter_sound.play()
				Globals.current_deleting_data[i] = deleted_character
			else:
				eat_nothing.pitch_scale = (.4 * Globals.current_deleting_data[i].length())
				eat_nothing.play()
	# print(text_to_show_lines)
	text_to_show = "\n".join(text_to_show_lines)
	

func zip_coming_characters(string_to_edit: String) -> String:
	var ret = []
	var lines = string_to_edit.split("\n")
	for i in range(lines.size()):
		if i < Globals.current_deleting_data.size() and Globals.current_deleting_data[i] != "":
			ret.append(lines[i] + "[color=red]" + Globals.current_deleting_data[i] + "[/color]")
		else:
			ret.append(lines[i])
	return "\n".join(ret)

func add_line_numbers(to_add_to: String) -> String:
	var lines = to_add_to.split("\n")
	for i in range(lines.size()):
		if player_current_line_number == i:
			lines[i] = "[bgcolor=#3e3d32]" + str(i + 1) + "|" + (">" if cursor_on else " ") + lines[i] + "[/bgcolor]"
		else:
			lines[i] = str(i + 1) + "|" + " " + lines[i]
	return "\n".join(lines) 

func get_formatted_text_to_show(to_format: String):
	var player_overall_pos = get_player_overall_pos()	
	var player_pos_showing = (to_format.substr(0, player_overall_pos) +
				"[u][color=green]" + to_format.substr(player_overall_pos, 1) + "[/color][/u][font_size=1].[/font_size]" +
				to_format.substr(player_overall_pos + 1))
			
#	print("player_pos_showing\n", player_pos_showing)
#	var lines_for_highlight = player_pos_showing.split("\n")
#	lines_for_highlight[player_current_line_number] = "[u]" + lines_for_highlight[player_current_line_number] + "[/u]"
#	var zipped = zip_coming_characters("\n".join(lines_for_highlight))
	var zipped = to_format
	if allowed_to_type:
		zipped = zip_coming_characters(to_format)
#	print("zipped\n", zipped)
	var with_line_numbers = add_line_numbers(zipped)
	var with_code_tag = Globals.add_code_tag_to_string(with_line_numbers)
#	print("with code tag\n", with_code_tag)
	var syntax_colored = add_syntax_coloring(with_code_tag)
	return syntax_colored

func add_syntax_coloring(to_color):
	var syntax_colored = (
		to_color.replace("output", "[color=#29c6f2]output[/color]")
   				.replace("goto", "[color=#c24810]goto[/color]")
   				.replace("store", "[color=#eb2fe4]store[/color]")
	)
	var regex = RegEx.new()
	regex.compile("(\\$[a-z]+)")
	syntax_colored = regex.sub(syntax_colored, "[color=#189e39]$1[/color]", true)
	regex = RegEx.new()
	regex.compile("( \\d+)")
	syntax_colored = regex.sub(syntax_colored, "[color=#7915eb]$1[/color]", true)
	return syntax_colored
	

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
	self.text = get_formatted_text_to_show(text_to_show)
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
	
	# print("left space is ", left_space)
	# print("right space is ", right_space)
	var word_on_cursor = text_to_show.substr(left_space, right_space - left_space)
	return word_on_cursor

func advance_level():
	if Globals.curret_output == Globals.current_level_goal:
		# print("level complete!")
		level_complete_sound.play()
		$startNewLevelTimer.start(1)

func _on_start_new_level_timer_timeout():
	Globals.current_level += 1
	Globals.restart_current_level()

func check_level_advance():
#	var word_on_cursor = get_word_on_cursor()
#	print("word on cursor is ", word_on_cursor)
#	if word_on_cursor.strip_edges() == next_level_text:
#		advance_level()
	pass

func set_register_values_in_string(string: String):
	var words = string.split(" ")
	print(words)
	for word in words:
		if word.begins_with("$"):
			var no_dollar = word.lstrip("$")
			if no_dollar.strip_edges() != "":
				Globals.registers[no_dollar] = Globals.registers.get(no_dollar, 0)
	print("after setting ", Globals.registers)

func run_current_line():
	var current_line_text = text_to_show.split("\n")[player_current_line_number]
	var words_on_line = current_line_text.strip_edges().split(" ")
	# print(current_line_text)
	# print(words_on_line)
	if words_on_line.size() <= 1:
		error_sound.pitch_scale = randf_range(.7, 1.3)
		error_sound.play()
		return
	if current_line_text.begins_with(output_word) and Globals.curret_output.length() < 5:
		if words_on_line[1].begins_with("$"):
			set_register_values_in_string(current_line_text)
			Globals.curret_output += str(Globals.registers[words_on_line[1].lstrip("$")])
		else:
			Globals.curret_output += words_on_line[1]
		print_sound.pitch_scale = randf_range(.8, 1.3)
		print_sound.play()
	elif current_line_text.begins_with("goto"):
		player_current_line_number = int(words_on_line[-1]) - 1
		update_pos_and_display()
		print_sound.pitch_scale = randf_range(.5, 1.5)
		jump_sound.play()
	elif current_line_text.begins_with("store"):
		if words_on_line.size() < 3:
			error_sound.pitch_scale = randf_range(.7, 1.3)
			error_sound.play()
			return
		set_register_values_in_string(current_line_text)
		var expression = Expression.new()
		var to_run = "".join(words_on_line.slice(3)).replace("$", "")
		print("to run ", to_run)
		expression.parse(to_run, Globals.registers.keys())
		var result = expression.execute(Globals.registers.values())
		if result == null:
			error_sound.pitch_scale = randf_range(.7, 1.3)
			error_sound.play()
		else:
			Globals.registers[words_on_line[1].lstrip("$")] = result
			print(Globals.registers)
			ding_sound.play()
			update_pos_and_display()
	
func show_backspace_coming():
	var test_string = """hi
	there
	buddy"""
	var backspace_regex = RegEx.new()
	backspace_regex.compile("(.+)\n")
	var replaced = backspace_regex.sub(test_string, "$1\n")
	# print(replaced)
	# print("a".repeat(6))
	

func check_input():
	var moved = false
	if not allowed_to_type:
		return
	if Input.is_action_just_pressed("enter_word"):
		# print("checking")
		run_current_line()	
		advance_level()
#		check_level_advance()
	if Input.is_action_just_pressed("reset"):
		Globals.should_play_reset_sound = true
		Globals.restart_current_level()
	if Input.is_action_just_pressed("down"):
		player_current_line_number += 1
		moved = true
	elif Input.is_action_just_pressed("up"):
		player_current_line_number -= 1
		moved = true
#	elif Input.is_action_just_pressed("left"):
#		player_pos_in_line -= 1
#		adjust_for_going_off_end_of_lines()
#		moved = true
#	elif Input.is_action_just_pressed("right"):
#		player_pos_in_line += 1
#		adjust_for_going_off_end_of_lines()
#		moved = true
	
	if moved:
		update_pos_and_display()
		move_deleting_characters()
		update_pos_and_display()
		
		# print("word on cursor is ", get_word_on_cursor())

func update_pos_and_display():
	adjust_for_edge_cases()
	update_text_display()
	

func _on_delete_from_end_timer_timeout():
#	text_to_show = text_to_show.substr(0, text_to_show.length() - 1)
#	update_text_display()
#	$deleteFromEndTimer.start()
	pass

func move_deleting_characters():
	remove_space_from_deleting_data_beginning()
	
	update_text_display()
	$moveInDeletingCharacters.start()

func _on_move_in_deleting_characters_timeout():
	pass
#	move_deleting_characters()



func _on_spawn_code_timer_timeout():
	level_typed_progress += 1
	self.text = get_formatted_text_to_show(text_to_show.substr(0, level_typed_progress))
	if typing_sound.playing == false:
		typing_sound.pitch_scale = randf_range(.5, 1.5)
		typing_sound.play()
	if level_typed_progress >= text_to_show.length():
		$spawnCodeTimer.stop()
		allowed_to_type = true
		update_text_display()
	pass # Replace with function body.





func _on_blink_cursor_timer_timeout():
	cursor_on = not cursor_on
	if allowed_to_type:
		update_text_display()
	$blinkCursorTimer.start(.6)
