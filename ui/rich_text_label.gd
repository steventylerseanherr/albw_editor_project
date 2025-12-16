extends RichTextLabel

func _process(delta):
	self.text = get_node("/root/Control/Scene/3dscene").name
