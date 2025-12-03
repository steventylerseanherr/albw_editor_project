extends Node

func _ready():
	var object = Node.new()
	object.name = "MyNode"
	get_node("/root/Control/Scene").add_child(object)

#https://nintendo-formats.com/libs/common/byaml.html
func _on_open_file_dialog_file_selected(path: String) -> void:
	var byaml_file = FileAccess.open(path,FileAccess.READ)
	var byaml_magic = byaml_file.get_16()
	var version_number = byaml_file.get_16()
	if byaml_magic != 16985:
		print("this is not a byaml file")
		return
	elif byaml_magic == 16985:
		print("byaml file validated")
		if version_number != 1:
			print("byaml has the wrong format version")
			return
		elif version_number == 1:
			print("byaml version number validated")
	var offset_to_dictionary_key_table = byaml_file.get_32()
	var offset_string_table = byaml_file.get_32()
	var offset_to_root_node = byaml_file.get_32()
	
	byaml_file.seek()
	offset_to_dictionary_key_table
