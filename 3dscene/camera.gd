extends Node3D
var currentpos = Vector2()
var lastpos = Vector2()
var movepos = Vector2()
var cammode = "orbit"

func _ready():
	$Camera3D.position += Vector3(0.0,0.0,10.0)	#sets default zoom on start

func _process(delta: float) -> void:
	currentpos=get_viewport().get_mouse_position()
	movepos=currentpos-lastpos
	
	if ! Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if Input.is_key_pressed(KEY_CTRL):
			cammode = "zoom"
		elif Input.is_key_pressed(KEY_SHIFT):
			cammode = "pan"
		else: 
			cammode = "orbit"
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		if get_viewport().get_mouse_position().x < 0.0: #wrap left to the right
			Input.warp_mouse(Vector2(get_viewport().size.x,get_viewport().get_mouse_position().y))
		if get_viewport().get_mouse_position().x > get_viewport().size.x:
			Input.warp_mouse(Vector2(0.0,get_viewport().get_mouse_position().y))
		if get_viewport().get_mouse_position().y < 0.0:
			Input.warp_mouse(Vector2(get_viewport().get_mouse_position().x,get_viewport().size.y))
		if get_viewport().get_mouse_position().y > get_viewport().size.y:
			Input.warp_mouse(Vector2(get_viewport().get_mouse_position().x,0.0))
		
		if cammode == "orbit":
			rotation += Vector3(-movepos.y/128,-movepos.x/128,0.0)
		elif cammode == "pan":
			position += global_transform.basis * Vector3(-movepos.x/128,movepos.y/128,0.0)
		elif cammode == "zoom":
			$Camera3D.position += Vector3(0.0,0.0,movepos.y/128)
			$Camera3D.position = clamp($Camera3D.position,Vector3(0,0,1),Vector3(0,0,10))

	lastpos=get_viewport().get_mouse_position()
