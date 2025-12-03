extends Node3D

var camyaw = 0.0
var campitch = 0.0
var camsensitivity = 0.002
var ignorenextmousemotion = false
var camx = 0.0
var camy = 0.0
var cammode = "orbit"
var mouse_delta = Vector2()
var lastpos = Vector2()
var currentpos = Vector2()

func _ready():
	$Camera3D.position += Vector3(0.0,0.0,10.0)

func _process(delta: float) -> void:
	print(lastpos-get_viewport().get_mouse_position())

func _input(event):
	if ! Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if Input.is_key_pressed(KEY_CTRL):
			cammode = "zoom"
		elif Input.is_key_pressed(KEY_SHIFT):
			cammode = "pan"
		else: 
			cammode = "orbit"
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			if get_viewport().get_mouse_position().x < 0.0:
				Input.warp_mouse(Vector2(get_viewport().size.x,get_viewport().get_mouse_position().y))
			if get_viewport().get_mouse_position().x > get_viewport().size.x:
				Input.warp_mouse(Vector2(0.0,get_viewport().get_mouse_position().y))
			if get_viewport().get_mouse_position().y < 0.0:
				Input.warp_mouse(Vector2(get_viewport().get_mouse_position().x,get_viewport().size.y))
			if get_viewport().get_mouse_position().y > get_viewport().size.y:
				Input.warp_mouse(Vector2(get_viewport().get_mouse_position().x,0.0))

			if cammode == "orbit":
				mouse_delta = get_viewport().get_mouse_position() - lastpos / 9999999  #* camsensitivity
				camyaw -= mouse_delta.x
				campitch = clamp(campitch - mouse_delta.y, deg_to_rad(-89), deg_to_rad(89))
				rotation.y = camyaw
				rotation.x = campitch
			elif cammode == "zoom":
				mouse_delta = event.relative * camsensitivity
				camy = mouse_delta.y
				$Camera3D.position += Vector3(0.0,0.0,camy*8)
				$Camera3D.position = clamp($Camera3D.position,Vector3(0,0,1),Vector3(0,0,10))
			elif cammode == "pan":
				mouse_delta = event.relative * camsensitivity
				camx = mouse_delta.x
				camy = mouse_delta.y
				position.y += camy
				position.x += -camx
		lastpos = get_viewport().get_mouse_position()
