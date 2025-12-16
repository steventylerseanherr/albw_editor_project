extends Node

var actor = {}
var actor_path = actor
var actor_current_path = []
var cursorpos = []

var node_read_string_table = []
var dictionary_key_table = []
var string_table = []
var node_start_pos

func read_cstring(file: FileAccess) -> String:	#function from chatgpt
	var bytes: PackedByteArray = []
	while not file.eof_reached():
		var b: int = file.get_8()
		if b == 0:
			break
		bytes.append(b)
	return bytes.get_string_from_utf8()

func _ready():
	var object = Node.new()
	object.name = "MyNode"
	get_node("/root/Control/Scene").add_child(object)
	
func read_current_node(target_file):
	print("check current node type at "+str(target_file.get_position()))
	node_start_pos = target_file.get_position()
	var nodetype = target_file.get_8()
	if nodetype == 0xc1:
		pass
	elif nodetype == 0xc2:
		var count = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
		var address_stack = []
		for each in range(count):
			address_stack.append(target_file.get_32())
		for each in range(count):
			target_file.seek(node_start_pos+address_stack[each])
			node_read_string_table.append(read_cstring(target_file))
	
	else:
		print("unimplemented node at "+str(target_file.get_position()))
	
func read_child_node():
	pass

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
	
	#print("reading dictionary key table")
	byaml_file.seek(offset_to_dictionary_key_table)
	read_current_node(byaml_file)
	dictionary_key_table = node_read_string_table.duplicate()	#get the string data out of temp array
	node_read_string_table.clear()					#clear temp array
	
	#print("reading string table")
	byaml_file.seek(offset_string_table)
	read_current_node(byaml_file)
	string_table = node_read_string_table.duplicate()	#get the string data out of temp array
	node_read_string_table.clear()					#clear temp array

	#print("reading root node")
	byaml_file.seek(offset_to_root_node)
	read_current_node(byaml_file)
	
	






	#for each in range(len(dictionary_key_table)):
	#	print(dictionary_key_table[each])

	#for each in range(len(string_table)):
	#	print(string_table[each])
