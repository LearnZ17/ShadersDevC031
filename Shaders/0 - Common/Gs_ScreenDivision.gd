extends Node

func _ready() -> void:
	var left_viewport := $SubViewportContainer/LSubViewport
	var right_viewport := $SubViewportContainer2/RSubViewport

	# En 2D: compartir el mismo World2D, de lo contrario ambas cámaras no verán el mismo nivel
	right_viewport.world_2d = left_viewport.world_2d

	_setup_viewport(left_viewport)
	_setup_viewport(right_viewport)

func _setup_viewport(viewport: SubViewport) -> void:
	# Ajustar el tamaño del viewport a la mitad de la ventana
	var window_size := DisplayServer.window_get_size()
	viewport.size = Vector2i(window_size.x / 2, window_size.y)
