extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = Globals.add_code_tag_to_string("Goal:   " + Globals.current_level_goal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
