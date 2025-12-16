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
	
func readc2node(target_file):	#might be pointless to keep seperate from readrootnode
	var nodetype = target_file.get_8()
	node_start_pos = target_file.get_position()-1
	if nodetype == 0xc2:	#0xc2 = string table
		var count = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
		var addresses = []
		for each in range(count+1):
			addresses.append(target_file.get_32())
		for each in range(count+1):
			target_file.seek(node_start_pos+addresses[each])
			node_read_string_table.append(read_cstring(target_file))




func read_node_type(target_file, actor_dict):
	print("check main node type at "+str(target_file.get_position()))
	var nodetype = target_file.get_8()
	if nodetype == 0xc0:    #0xc0 = array
		#print("reading main node type 0xc0 at "+str(target_file.get_position()))
		var count = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
		var sub_node_type = []
		var sub_node_value = []
		for each in range(count):
			sub_node_type.append(target_file.get_8())
		target_file.seek((target_file.get_position()+3)&~3)
		for each in range(count):
			sub_node_value.append(target_file.get_32())
		#var child
		#for each in range(count):
		#	if sub_node_type[each] == 0xc0:
		#		actor_dict.append([])					#creates OBJ dictionary
		#	elif sub_node_type[each] == 0xc1:
		#		actor_dict.append({})
		
		for each in range(count):
			#child = actor_dict
			read_sub_node_type(target_file, actor_dict, sub_node_type[each], sub_node_value[each])

	elif nodetype == 0xc1:	#0xc1 = dictionary
		#print("reading main node type 0xc1 at "+str(target_file.get_position()))
		var count = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
		for each in range(count):   #### SET TO COUNT
			var index_into_dictionary_key_table = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
			var sub_node_type = target_file.get_8()
			var sub_node_value = target_file.get_32()
			var child
			if sub_node_type == 0xff:
				actor_dict[dictionary_key_table[index_into_dictionary_key_table]] = []					#creates OBJ dictionary
			else:#if sub_node_type == 0xc0:
				actor_dict[dictionary_key_table[index_into_dictionary_key_table]] = {}					#creates OBJ dictionary
			child = actor_dict[dictionary_key_table[index_into_dictionary_key_table]]
			actor_current_path.append(dictionary_key_table[index_into_dictionary_key_table])												#saves parent dictionary

			read_sub_node_type(target_file, child, sub_node_type, sub_node_value)
			
	elif nodetype == 0xc2:  #0xc2 = string table
		#print("reading main node type 0xc2 at "+str(target_file.get_position()))
		var count = target_file.get_8()+(target_file.get_8()*0x100)+(target_file.get_8()*0x10000)
		var addresses = []
		for each in range(count+1):
			addresses.append(target_file.get_32())
		for each in range(count+1):
			target_file.seek(node_start_pos+addresses[each])
			node_read_string_table.append(read_cstring(target_file))

	else:
		print("!!!UNKNOWN MAIN NODE TYPE FOUND AT "+str(target_file.get_position())+" !!!")
		return

func read_sub_node_type(target_file, actor_dict, sub_node_type, sub_node_value):
	#print("check sub node type at "+str(target_file.get_position()))
	if sub_node_type == 0xa0:
		pass
		#print("unimplemented sub node type 0xa0")
	elif sub_node_type == 0xa1:
		pass
		#print("unimplemented sub node type 0xa1")
	elif sub_node_type == 0xa2:
		pass
		#print("unimplemented sub node type 0xa2")
	elif sub_node_type == 0xc0 || sub_node_type == 0xc1 || sub_node_type == 0xc2 || sub_node_type == 0xc3 || sub_node_type == 0xc4:
		#print("reading sub node type 0xc0 - 0xc4")
		cursorpos.append(target_file.get_position())
		target_file.seek(sub_node_value)
		read_node_type(target_file, actor_dict)
		target_file.seek(cursorpos[len(cursorpos)-1])
		cursorpos.pop_back()
	elif sub_node_type == 0xd0 || sub_node_type == 0xd1 || sub_node_type == 0xd2 || sub_node_type == 0xd3:
		pass
		#print("unimplemented sub node type 0xd0 - 0xd3")
	elif sub_node_type == 0xd4 || sub_node_type == 0xd5 || sub_node_type == 0xd6:
		pass
		#print("unimplemented subnode type 0xd4 - 0xd6")
	else:
		print("!!!UNKNOWN_SUB_NODE_TYPE_FOUND!!!")
		return


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
	
	#print("reading dictionary key table")
	byaml_file.seek(offset_to_dictionary_key_table)
	readc2node(byaml_file)
	dictionary_key_table = node_read_string_table.duplicate()	#get the string data out of temp array
	node_read_string_table.clear()					#clear temp array
	
	#print("reading string table")
	byaml_file.seek(offset_string_table)
	readc2node(byaml_file)
	string_table = node_read_string_table.duplicate()	#get the string data out of temp array
	node_read_string_table.clear()					#clear temp array
	
	#print("reading root node")
	byaml_file.seek(offset_to_root_node)
	read_node_type(byaml_file, actor)

	print(actor)
	print("breakpoint")
