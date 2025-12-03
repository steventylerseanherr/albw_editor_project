extends Node3D

var camyaw = 0.0
var campitch = 0.0
var camsensitivity = 0.002
var ignorenextmousemotion = false
var camx = 0.0
var camy = 0.0

func _ready():
	$Camera3D.position += Vector3(0.0,0.0,10.0)

var mouse_delta = Vector2()
func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_delta = event.relative * camsensitivity

			camx = mouse_delta.x
			camy = mouse_delta.y
			if Input.is_key_pressed(KEY_SHIFT):
				position.y += camy
				position.x += -camx
			else:
				camyaw -= mouse_delta.x
				campitch = clamp(campitch - mouse_delta.y, deg_to_rad(-89), deg_to_rad(89))
				rotation.y = camyaw
				rotation.x = campitch
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
	#	$Camera3D.position += Vector3(0.0,0.0,-1.0)
	#	$Camera3D.position = $Camera3D.position.clamp(Vector3(0,0,1),Vector3(0,0,10))
	#	print("zoom in")
	#	print($Camera3D.position)
		
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
	#	$Camera3D.position += Vector3(0.0,0.0,1.0)
	#	$Camera3D.position = $Camera3D.position.clamp(Vector3(0,0,1),Vector3(0,0,10))
	#	print("zoom in")
	#	print($Camera3D.position)

func _process(delta: float) -> void:
	pass
	#print(position)
		
		#if Input.is_key_pressed(KEY_SHIFT):
			#print("start moving origin")
		
		#else:
			#print(mouse_delta)
			#rotation.y = camyaw
			#rotation.x = campitch

	#else:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
