extends RichTextLabel

var text_to_show: String = """
goto 3
goto 5
exit
say hi
""".strip_edges()

var player_current_line_number = 0
var player_pos_in_line = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = get_formatted_text_to_show()

func get_formatted_text_to_show():
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
			
	return ("[code]" + 
				text_to_show.substr(0, player_overall_pos) +
				"[u][color=green]" + text_to_show.substr(player_overall_pos, 1) + "[/color][/u]" +
				text_to_show.substr(player_overall_pos + 1) + 
			"[/code]")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_movement()
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
	

func _on_delete_from_end_timer_timeout():
	text_to_show = text_to_show.substr(0, text_to_show.length() - 1)
	update_text_display()
	$deleteFromEndTimer.start()
	
func update_text_display():
	self.text = get_formatted_text_to_show()
	print("current line is ", player_current_line_number)
	print("current pos in line is ", player_pos_in_line)

func check_movement():
	var moved = false
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










