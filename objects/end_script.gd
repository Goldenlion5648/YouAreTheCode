extends RichTextLabel

var type_progress = 0
var to_show = """Thank you for playing!"""


var can_start_game = false
@onready var typing_sound = $typingSound

var has_seen_new_line = false


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
		Globals.current_level = 0
		get_tree().change_scene_to_file("res://objects/main_scene.tscn")


func _on_intro_timer_timeout():
	type_progress += 1
	self.text = add_formatting(to_show.substr(0, type_progress))
	var done_typing = false
	if type_progress >= to_show.length() + 30:
		can_start_game = true
		$hintText.visible = true
	if type_progress >= to_show.length():
		done_typing = true
	if not typing_sound.playing and not done_typing:
		typing_sound.pitch_scale = randf_range(.7, 1.3)
		typing_sound.play()
	if type_progress < to_show.length() and to_show.substr(type_progress-1, 1) == "\n":
		if not has_seen_new_line:
			$introTimer.start(1)
			has_seen_new_line = true
	else:
		$introTimer.start(0.04)
	pass # Replace with function body.



