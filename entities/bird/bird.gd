extends RigidBody2D

var was_shot: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# "Se o pássaro já foi atirado e sua velocidade é menor que X, Despawn"
	if was_shot:
		pass
