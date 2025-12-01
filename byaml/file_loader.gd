extends Node

#func open_dialog():
#	var fd := FileDialog.new()
#	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
#	fd.access = FileDialog.ACCESS_FILESYSTEM
#	fd.filters = ["*.byaml"]

#	add_child(fd)
#	fd.file_selected.connect(_on_file_selected)
#	fd.popup_centered()

#func _on_file_selected(path: String):
#	print("You chose:", path)

#func _on_button_pressed() -> void:
#	$FileDialog.visible = true
#	
#	get_node("/root/Control/Button").queue_free()	#deletes test load button

@onready var menu_button = $"../MenuButton"   # adjust path as needed

func _ready():
	var popup = $/root/Control/MenuBar/file.get_popup()
	popup.id_pressed.connect(_on_file_pressed)

func _on_file_pressed(id: int) -> void:
	match id:
		0:
			$open_FileDialog.visible = true
		1:
			$save_FileDialog.visible = true
		2:
			pass #needs to clear the entire scene

func _on_file_dialog_file_selected(path: String) -> void:
	var byaml_file := FileAccess.open(path,FileAccess.READ)
	print(byaml_file.get_8())
