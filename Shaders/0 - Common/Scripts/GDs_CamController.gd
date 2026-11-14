extends Node3D

@export var sensitivity: float = 0.5
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 25.0
@export var max_zoom: float = 100.0

@onready var horizontal_pivot: Node3D = self
@onready var vertical_pivot: Node3D = $Vertical_X_Pivot # El nodo hijo para el eje X
@onready var spring_arm: SpringArm3D = $Vertical_X_Pivot/SpringArm3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotación horizontal (Yaw)
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		
		# Rotación vertical (Pitch) con límites
		vertical_pivot.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		vertical_pivot.rotation.x = clamp(
			vertical_pivot.rotation.x, 
			deg_to_rad(-60), 
			deg_to_rad(60)
		)

	# Zoom con la rueda del ratón
	if event.is_action_pressed("zoom_in"):
		spring_arm.spring_length = clamp(spring_arm.spring_length - zoom_speed, min_zoom, max_zoom)
	if event.is_action_pressed("zoom_out"):
		spring_arm.spring_length = clamp(spring_arm.spring_length + zoom_speed, min_zoom, max_zoom)
