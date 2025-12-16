extends Node

var data
var keys
var strings

enum Type {
	STRING = 0xA0,
	ARRAY = 0xC0,
	DICT = 0xC1,
	STRINGS = 0xC2,
	BOOL = 0xD0,
	INT = 0xD1,
	FLOAT = 0xD2,
}

func decode_root():
	var root = data.decode_u32(0xC)
	return decode_node(root)

func decode_node(offset):
	var type_count = decode_type_count(data.decode_u32(offset))
	var items = data.slice(offset + 4)
	var count = type_count.count
	match type_count.type:
		Type.ARRAY:
			var types = items.slice(0, count)
			var pad_count = (count + 3) & 0xFFFFFC
			var values = items.slice(pad_count, pad_count + 4 * count)
			var array = []
			for i in range(count):
				var value = values.slice(i * 4, i * 4  + 4)
				array.push_back(decode_value(types[i], value))
			return array
		Type.DICT:
			var dict = {}
			for i in range(count):
				var type_key = items.decode_u32(i * 8)
				var type = (type_key >> 24) & 0xFF
				var index = type_key & 0xFFFFFF
				var key = keys[index]
				var value = items.slice(i * 8 + 4, i * 8 + 8)
				dict[key] = decode_value(type, value)
			return dict
		_:
			return # error (unknown type)

func decode_type_count(head):
	return { type = head & 0xFF, count = head >> 8 }

func decode_value(type, bytes):
	match type:
		Type.STRING:
			return strings[bytes.decode_u32(0)]
		Type.BOOL:
			return bytes.decode_u32(0) == 1
		Type.INT:
			return bytes.decode_s32(0)
		Type.FLOAT:
			return bytes.decode_float(0)
		_:
			return decode_node(bytes.decode_u32(0))

func decode_string_table(data):
	var type_count = decode_type_count(data.decode_u32(0))
	var count = type_count.count
	if type_count.type == Type.STRINGS:
		var offsets = data.slice(4, 4 + 4 * (count + 1)).to_int32_array()
		var strings = []
		for i in range(count):
			var start = offsets[i]
			var end = offsets[i + 1]
			if data[end - 1] == 0:
				strings.push_back(data.slice(start, end - 1).get_string_from_ascii())
			else:
				return # error (not nul-terminated)
		return strings
	else:
		return # error (wrong type)

func _readbyaml(data):
	self.data = data
	var keys = self.data.decode_u32(0x4)
	self.keys = decode_string_table(data.slice(keys))
	var strings = self.data.decode_u32(0x8)
	self.strings = decode_string_table(data.slice(strings))


func _ready():
	var object = Node.new()
	object.name = "MyNode"
	get_node("/root/Control/Scene").add_child(object)

func _on_open_file_dialog_file_selected(path: String) -> void:
	var byaml_file = FileAccess.open(path,FileAccess.READ)
	var bytes: PackedByteArray = byaml_file.get_buffer(byaml_file.get_length())
	byaml_file.close()

	_readbyaml(bytes)

	print(decode_root().keys())
