extends RigidBody2D

var is_launched: bool = false
var idle_time: float = 0.0

@export var max_idle_time: float = 2.0
@export var min_speed: float = 15.0

func _physics_process(delta: float) -> void:
	# Não faz nada se ainda estiver preso no estilingue
	if not is_launched:
		return
	
	# Se a velocidade for muito baixa ou a física da engine colocar ele pra "dormir"
	if linear_velocity.length() < min_speed or sleeping:
		idle_time += delta
		if idle_time >= max_idle_time:
			despawn()
	else:
		# Reseta o timer se ele voltar a se mover rápido (ex: rolou ladeira abaixo)
		idle_time = 0.0

func despawn() -> void:
	# Aqui, no futuro, avisaremos o Event Bus que o pássaro morreu para recarregar o estilingue
	queue_free()
