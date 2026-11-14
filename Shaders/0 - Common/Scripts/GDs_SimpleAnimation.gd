extends Node3D

# Asume que el AnimationPlayer está en la jerarquía de tu modelo
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Reproduce una animación por su nombre exacto de Blender
	animation_player.current_animation = "Idle_animation"
	
	if animation_player.has_animation("Idle_animation"):
		animation_player.play("Idle_animation")
