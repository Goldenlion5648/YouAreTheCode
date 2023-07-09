extends RichTextLabel


var keys_seen = []
func _ready():
	keys_seen.clear()
	pass
func update_text():
	if Globals.current_level_data.contains("$") == false:
		self.text = ""
		return
	var temp = []
	var keys = Globals.registers.keys()
	for key in keys:
		if key not in keys_seen:
			keys_seen.append(key)
#	keys.sort()
#	print(keys_seen)
#	print(Globals.registers)
	for key in keys_seen:
		if key in Globals.registers:
			temp.append(key + ": " + str(Globals.registers[key]))
	self.text = Globals.add_format_tag_to("center", 
		Globals.add_code_tag_to_string("Stored Values:\n" + "\n".join(temp)))

func _process(delta):
	update_text()

