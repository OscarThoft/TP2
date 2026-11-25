extends CharacterBody2D

@export var max_health := 25.0
@export var patrol_distance := 100.0
@export var patrol_speed := 45.0
@export var chase_speed := 80.0
@export var detection_radius := 180.0
@export var lose_radius := 240.0

const WALK_FRAME_COUNT := 6
const WALK_ANIMATION_SPEED := 9.0

var health := max_health
var patrol_direction := 1.0
var is_chasing := false
var animation_time := 0.0
var patrol_origin_x := 0.0

@onready var walking_sprite: Sprite2D = $WalkingSprite
@onready var player: CharacterBody2D = get_node_or_null("../TestPlayer")

func _ready() -> void:
	patrol_origin_x = global_position.x

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_node_or_null("../TestPlayer")

	if player != null:
		var distance_to_player := global_position.distance_to(player.global_position)
		if is_chasing:
			if distance_to_player > lose_radius:
				is_chasing = false
		else:
			is_chasing = distance_to_player <= detection_radius

	var target_x := patrol_origin_x + patrol_direction * patrol_distance
	var move_speed := patrol_speed
	if is_chasing:
		target_x = player.global_position.x
		move_speed = chase_speed
	elif absf(global_position.x - target_x) <= 4.0:
		patrol_direction *= -1.0
		target_x = patrol_origin_x + patrol_direction * patrol_distance

	var horizontal_direction := signf(target_x - global_position.x)
	velocity.x = move_toward(velocity.x, horizontal_direction * move_speed, 400.0 * delta)
	if not is_on_floor():
		velocity.y += 1500.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()
	if is_on_wall() and not is_chasing:
		patrol_direction *= -1.0
	_update_animation(delta)

func _update_animation(delta: float) -> void:
	animation_time += delta
	walking_sprite.frame = int(animation_time * WALK_ANIMATION_SPEED) % WALK_FRAME_COUNT
	if absf(velocity.x) > 1.0:
		walking_sprite.flip_h = velocity.x > 0.0