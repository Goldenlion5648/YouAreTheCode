extends RichTextLabel

var type_progress = 0
var to_show = """Now you are the computer! 
Don't let the code that you need get deleted by the user!"""
var can_start_game = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_formatting(to_format: String):
	return (
		"[center]" + 
		Globals.add_code_tag_to_string(to_format) +
		"[/center]" 
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("enter_word") and can_start_game:
		get_tree().change_scene_to_file("res://objects/main_scene.tscn")


func _on_intro_timer_timeout():
	type_progress += 1
	self.text = add_formatting(to_show.substr(0, type_progress))
	if type_progress >= to_show.length() + 30:
		can_start_game = true
		$hintText.visible = true
	$introTimer.start(.04)
	pass # Replace with function body.
