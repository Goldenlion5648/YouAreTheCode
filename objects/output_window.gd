extends RichTextLabel


func _ready():
	self.text = Globals.formatted_output

func _process(delta):
	self.text = Globals.formatted_output

