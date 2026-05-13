extends Node2D

@onready var exterior: Node2D = $Exterior
@onready var interior: Node2D = $Interior
@onready var exterior_door: Area2D = $Exterior/DoorArea
@onready var interior_door: Area2D = $Interior/DoorArea
@onready var player: CharacterBody2D = $CargoPlayer
@onready var instructions: Label = $Hud/Instructions

const EXTERIOR_BOUNDS := Rect2(-544.0, -352.0, 1088.0, 704.0)
const INTERIOR_BOUNDS := Rect2(-265.0, -265.0, 530.0, 530.0)
const EXTERIOR_ENTRY_POSITION := Vector2(0.0, 270.0)
const INTERIOR_ENTRY_POSITION := Vector2(0.0, 130.0)

var _transition_locked := false


func _ready() -> void:
	exterior_door.body_entered.connect(_on_exterior_door_entered)
	interior_door.body_entered.connect(_on_interior_door_entered)
	_show_exterior(Vector2(0.0, 250.0))


func _on_exterior_door_entered(body: Node2D) -> void:
	if body == player and not _transition_locked:
		call_deferred("_show_interior", INTERIOR_ENTRY_POSITION)


func _on_interior_door_entered(body: Node2D) -> void:
	if body == player and not _transition_locked:
		call_deferred("_show_exterior", EXTERIOR_ENTRY_POSITION)


func _show_exterior(player_position: Vector2) -> void:
	_begin_transition()
	exterior.visible = true
	interior.visible = false
	exterior.process_mode = Node.PROCESS_MODE_INHERIT
	interior.process_mode = Node.PROCESS_MODE_DISABLED
	player.global_position = player_position
	player.velocity = Vector2.ZERO
	player.movement_bounds = EXTERIOR_BOUNDS
	instructions.text = "Dis mekan - kapidan iceri gir"
	_end_transition_after_delay()


func _show_interior(player_position: Vector2) -> void:
	_begin_transition()
	exterior.visible = false
	interior.visible = true
	exterior.process_mode = Node.PROCESS_MODE_DISABLED
	interior.process_mode = Node.PROCESS_MODE_INHERIT
	player.global_position = player_position
	player.velocity = Vector2.ZERO
	player.movement_bounds = INTERIOR_BOUNDS
	instructions.text = "Ic mekan - alt kapidan disari cik"
	_end_transition_after_delay()


func _begin_transition() -> void:
	_transition_locked = true
	exterior_door.monitoring = false
	interior_door.monitoring = false


func _end_transition_after_delay() -> void:
	await get_tree().create_timer(0.35).timeout
	exterior_door.monitoring = exterior.visible
	interior_door.monitoring = interior.visible
	_transition_locked = false
