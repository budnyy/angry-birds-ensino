extends RigidBody2D

@export var health: float = 500.0

func _ready() -> void:
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		var relative_velocity = (body.linear_velocity - linear_velocity).length()
		
		# Força = Velocidade da batida * Massa do objeto que bateu
		var impact_force = relative_velocity * body.mass
		
		# Limite para ignorar toques leves
		if impact_force > 300.0:
			take_damage(impact_force)

func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	# (Futuro), colocar uma animação quebrando e um efeito sonoro
	queue_free()
