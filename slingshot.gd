extends Node2D 

@onready var area_min: Area2D = $AreaMin
@onready var area_min_shape: CollisionShape2D = $AreaMin/CollisionShape2D

# Array de PackedScenes dos pássaros
@export var birds_queue: Array[PackedScene]

# Variável referência do pássaro atual que está no estilingue
var current_bird: RigidBody2D = null

# Area onde o pássaro será puxado. O centro da area_min
@onready var slingshot_center: Vector2 = area_min.global_position

# Estados da máquina de estado
enum SlingshotStates {Idle, Charging, Shot, Reset}

# Inicia-se no estado Reset para engatilhar o primeiro pássaro
var current_state: SlingshotStates = SlingshotStates.Reset

const GRAVITY := 980.0

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	match current_state:
		SlingshotStates.Idle:
			_state_idle(delta)
		SlingshotStates.Charging:
			_state_charging(delta)
		SlingshotStates.Shot:
			_state_shot(delta)
		SlingshotStates.Reset:
			_state_reset(delta)


func _state_idle(delta: float):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var distance = get_global_mouse_position().distance_to(slingshot_center)
		if distance <= area_min_shape.shape.radius:
			current_state = SlingshotStates.Charging

func _state_charging(delta: float):
	pass

func _state_shot(delta: float):
	pass

func _state_reset(delta: float):
	# Verifica se ainda tem munição (pássaros na fila)
	if (birds_queue.size() > 0):
		# Pega e remove o primeiro pássaro da fila (Array)
		var next_bird_scene = birds_queue.pop_front()
		
		# Instancia a cena do pássaro na memória
		current_bird = next_bird_scene.instantiate()
		
		# Adiciona o pássaro instanciado como filho da cena principal para aparecer no jogo
		# Usa-se get_tree().current_scene para não prender o pássaro à hierarquia do estilingue
		get_tree().current_scene.add_child(current_bird)
		
		# Move o pássaro para o centro do estilingue
		current_bird.global_position = slingshot_center
		
		# Transita para o estado Idle, aguardando o jogador clicar e puxar
		current_state = SlingshotStates.Idle
	else:
		# Se a fila estiver vazia, o jogador ficou sem munição.
		print("Sem munição! Fim de jogo ou Vitória.")
