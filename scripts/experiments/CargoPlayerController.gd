extends CharacterBody2D

@export var walk_speed := 120.0
@export var acceleration := 850.0
@export var friction := 1100.0
@export var bob_amount := 3.0
@export var bob_speed := 10.0
@export var movement_bounds := Rect2(-528.0, -336.0, 1056.0, 672.0)
@export var sprite_rest_offset := Vector2(0.0, -24.0)
@export var shadow_rest_scale := Vector2(0.68, 0.18)

@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Shadow

var _walk_time := 0.0

func _physics_process(delta: float) -> void:
	var input_direction := _get_input_direction()
	var target_velocity := input_direction * walk_speed
	var rate := acceleration if input_direction != Vector2.ZERO else friction

	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
	global_position = global_position.clamp(movement_bounds.position, movement_bounds.end)

	if input_direction != Vector2.ZERO:
		_walk_time += delta * bob_speed
	else:
		_walk_time = move_toward(_walk_time, 0.0, delta * bob_speed)

	_update_sprite_motion(input_direction)


func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	return direction.normalized()


func _update_sprite_motion(input_direction: Vector2) -> void:
	if input_direction.x != 0.0:
		sprite.flip_h = input_direction.x < 0.0

	if velocity.length() > 1.0:
		var bob := sin(_walk_time) * bob_amount
		sprite.position = sprite_rest_offset + Vector2(0.0, bob)
		sprite.rotation = sin(_walk_time * 0.5) * 0.04
		shadow.scale = shadow_rest_scale + Vector2(abs(bob) * 0.015, abs(bob) * 0.004)
	else:
		sprite.position = sprite.position.lerp(sprite_rest_offset, 0.25)
		sprite.rotation = lerpf(sprite.rotation, 0.0, 0.25)
		shadow.scale = shadow.scale.lerp(shadow_rest_scale, 0.25)
