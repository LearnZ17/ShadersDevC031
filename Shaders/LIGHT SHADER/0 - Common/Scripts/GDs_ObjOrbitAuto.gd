extends Node3D

@export var target: Node3D = null ## Nodo al que el Node3D orbitará (opcional)
@export var fixed_point: Vector3 = Vector3(0, 0, 0) ## Punto fijo en el espacio si no hay un nodo objetivo
@export var distance: float = 5.0 ## Radio de la órbita (distancia al centro)
@export var rotation_speed: float = 1.0 ## Velocidad de giro en radianes por segundo
@export var base_height: float = 2.0 ## Altura del nodo respecto al punto central

@export_group("Efecto de Flotación")
@export var float_amplitude: float = 0.5 ## Cuánto sube y baja el objeto verticalmente
@export var float_frequency: float = 2.0 ## Velocidad con la que oscila el movimiento de flotación

var current_angle: float = 0.0
var time_passed: float = 0.0

func _process(delta: float) -> void:
	# 1. Incrementar el ángulo continuamente con el tiempo
	current_angle += rotation_speed * delta
	time_passed += delta
	
	# 2. Obtener la posición del centro (nodo objetivo o vector fijo)
	var center_pos: Vector3 = target.global_position if target else fixed_point
	
	# 3. Calcular la nueva posición en coordenadas cartesianas
	var x = center_pos.x + cos(current_angle) * distance
	var z = center_pos.z + sin(current_angle) * distance
	#var y = center_pos.y + height
	
	var y = center_pos.y + base_height + sin(time_passed * float_frequency) * float_amplitude
	
	# Aplicar la posición al Node3D
	global_position = Vector3(x, y, z)
	
	# 4. Forzar el 'look_at' hacia el punto central (su eje -Z apuntará al objetivo)
	look_at(center_pos, Vector3.UP)
