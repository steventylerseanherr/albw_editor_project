extends Node

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
