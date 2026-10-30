extends Node2D 

@export var birds_queue: Array[PackedScene]
@export var max_drag_distance: float = 100.0 # Distância máxima que o elástico estica
@export var launch_force_multiplier: float = 10.0 # Multiplicador da força do tiro

@onready var grab_area: Area2D = $GrabArea
@onready var grab_shape: CollisionShape2D = $GrabArea/CollisionShape2D
@onready var center_point: Marker2D = $CenterPoint

@onready var front_band: Line2D = $FrontBand
@onready var back_band: Line2D = $BackBand

var current_bird: RigidBody2D = null

enum SlingshotStates {Idle, Charging, Shot, Reset}
var current_state: SlingshotStates = SlingshotStates.Reset

func _ready() -> void:
	# Esconde os elásticos inicialmente
	front_band.hide()
	back_band.hide()

func _process(delta: float) -> void:
	match current_state:
		SlingshotStates.Idle:
			_state_idle()
		SlingshotStates.Charging:
			_state_charging()
		SlingshotStates.Shot:
			_state_shot()
		SlingshotStates.Reset:
			_state_reset()

func _state_idle() -> void:
	if Input.is_action_just_pressed("ui_touch"): # Recomendado criar essa action no Input Map (Mouse Left)
		var mouse_pos = get_global_mouse_position()
		var distance = mouse_pos.distance_to(center_point.global_position)
		
		# Verifica se clicou dentro do raio do estilingue
		if distance <= grab_shape.shape.radius:
			current_state = SlingshotStates.Charging
			front_band.show()
			back_band.show()

func _state_charging() -> void:
	var mouse_pos = get_global_mouse_position()
	var center_pos = center_point.global_position
	
	# Calcula o vetor do centro até o mouse e limita o tamanho à max_drag_distance
	var drag_vector = mouse_pos - center_pos
	if drag_vector.length() > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance
	
	var bird_target_pos = center_pos + drag_vector
	
	# Move o pássaro
	if current_bird:
		current_bird.global_position = bird_target_pos
	
	# Atualiza o desenho dos elásticos (ponto 0 no estilingue, ponto 1 no pássaro)
	front_band.set_point_position(0, center_pos) # O ideal é deslocar um pouco para a haste da frente
	front_band.set_point_position(1, bird_target_pos)
	back_band.set_point_position(0, center_pos)  # O ideal é deslocar um pouco para a haste de trás
	back_band.set_point_position(1, bird_target_pos)
	
	# Dispara ao soltar o clique
	if Input.is_action_just_released("ui_touch"):
		current_state = SlingshotStates.Shot

func _state_shot() -> void:
	front_band.hide()
	back_band.hide()
	
	if current_bird:
		# Calcula a força invertendo o vetor de puxada (centro - posição atual do pássaro)
		var drag_vector = current_bird.global_position - center_point.global_position
		var impulse = -drag_vector * launch_force_multiplier
		
		# Ativa a física do pássaro e aplica o impulso
		current_bird.freeze = false
		current_bird.apply_central_impulse(impulse)
		
		# Desvincula o pássaro atual para não modificá-lo mais
		current_bird = null
		
	# A transição de volta para o Reset vai depender do Event Bus (quando a câmera voltar)
	# Por enquanto, não vamos forçar o Reset automático para não instanciar vários pássaros.

func _state_reset() -> void:
	if birds_queue.size() > 0:
		var next_bird_scene = birds_queue.pop_front()
		current_bird = next_bird_scene.instantiate()
		
		get_tree().current_scene.add_child(current_bird)
		current_bird.global_position = center_point.global_position
		
		# Congela o RigidBody para ele não cair por causa da gravidade enquanto está no estilingue
		current_bird.freeze = true 
		
		current_state = SlingshotStates.Idle
	else:
		print("Sem munição! Aguardando condição de vitória/derrota.")
		current_state = SlingshotStates.Idle
