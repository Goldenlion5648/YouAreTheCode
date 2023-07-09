extends RichTextLabel
var eaterText = "--<---<--<---<--<---<--<---<--<---<-"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_eater_timer_timeout():
	print("ticking")
	eaterText = eaterText.substr(1) + eaterText[0]
	self.text = Globals.add_code_tag_to_string(Globals.add_format_tag_to("center", "[color=red]" + eaterText +"[/color]"))
	$eaterTimer.start(1)
	pass # Replace with function body.
