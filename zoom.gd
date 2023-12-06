extends Sprite2D

var window = Rect2(-2.75, -1.5, 4.0, 3.0)
var zoom_delta = 1.2
var dither: bool = true

var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	set_shader_window()
	material.set_shader_parameter("dither", dither)
	screen_size = get_viewport().size


func set_shader_window():
	# send arguments to shader
	material.set_shader_parameter("xmin", window.position.x)
	material.set_shader_parameter("xmax", window.end.x)
	material.set_shader_parameter("ymin", window.position.y)
	material.set_shader_parameter("ymax", window.end.y)


func screen_to_coord(pos: Vector2):
	var uv = pos / screen_size
	return window.position + window.size * uv
	
	
func coord_to_screen(pos: Vector2):
	var uv = (pos - window.position) / window.size
	return uv * screen_size


func zoom(amount: float):
	# grow or shrink the size of the window rect2
	# ... then move window.position so that the mouse pointed to the same spot before and after
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_coord = screen_to_coord(mouse_pos)
	window.size /= amount

	# how far did the mouse mouse in coordinate space?
	window.position -= screen_to_coord(mouse_pos) - mouse_coord
	set_shader_window()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom(zoom_delta)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom(1.0 / zoom_delta)

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			window.position -= event.relative / screen_size * window.size
			set_shader_window()
			
			var pos = get_viewport().get_mouse_position()
			
	if event is InputEventKey:
		if event.is_action_pressed("toggle_dither"):
			dither = not dither
			material.set_shader_parameter("dither", dither)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
