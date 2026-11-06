extends RigidBody2D

@export var health: float = 500.0

func _ready() -> void:
	# Conecta o sinal de colisão
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Verifica se a colisão ocorreu entre dois corpos com física
	if body is RigidBody2D:
		# Pega a velocidade de quem bateu menos a velocidade do objeto ou inimigo
		var relative_velocity = (body.linear_velocity - linear_velocity).length()
		
		# Ignora toques leves (como um bloco apenas apoiado no outro)
		if relative_velocity > 100.0:
			take_damage(relative_velocity)

func take_damage(amount: float) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die() -> void:
	# (Futuro), colocar uma animação quebrando e um efeito sonoro
	queue_free()
