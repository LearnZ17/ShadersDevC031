extends Node3D

@export var target: Node3D = null ## Nodo opcional al que el pivote seguirá automáticamente
@export var distance: float = 5.0 ## Distancia inicial de la cámara al objetivo
@export var mouse_sensitivity: float = 0.005
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

var yaw: float = 0.0
var pitch: float = 0.0

@onready var camera: Camera3D = $Camera3D3

func _ready() -> void:
	# Asegurar la distancia inicial en el eje Z de la cámara
	camera.position = Vector3(0, 0, distance)

func _unhandled_input(event: InputEvent) -> void:
	# Rotar con el botón central del ratón (clic rueda) o mantén presionado clic derecho si prefieres
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		
		# Limitar el ángulo vertical para que la cámara no dé la vuelta completa
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		
		rotation.y = yaw
		rotation.x = pitch

	# Zoom con la rueda del ratón
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			distance = max(1.0, distance - 0.5)
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(500.0, distance + 0.5)
		
		# Aplicar el zoom de forma fluida o directa en la posición local Z de la cámara
		camera.position.z = distance

func _process(delta: float) -> void:
	# Si se asigna un nodo objetivo, el pivote lo seguirá de manera instantánea
	if target:
		global_position = target.global_position
