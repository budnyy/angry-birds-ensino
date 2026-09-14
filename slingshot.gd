extends Node2D 

@onready var area_min: Area2D = $AreaMin
@onready var area_min_shape: CollisionShape2D = $AreaMin/CollisionShape2D

enum SlingshotStates {Idle, Charging, Shot, Reset}
var current_state: SlingshotStates = SlingshotStates.Idle

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
		var distance = get_global_mouse_position().distance_to(area_min.global_position)
		if distance <= area_min_shape.shape.radius:
			current_state = SlingshotStates.Charging

func _state_charging(delta: float):
	pass

func _state_shot(delta: float):
	pass

func _state_reset(delta: float):
	pass
