@tool
extends Control

signal speed_changed(speed: int)

const HORIZONTAL_MARGIN_RATIO := 0.05

@onready var content_margin: MarginContainer = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin
@onready var time_label: Label = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/DaySlot/DayStat/Text/Value
@onready var gold_label: Label = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/GoldSlot/GoldStat/Text/Value
@onready var cargo_label: Label = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/CargoSlot/CargoStat/Text/Value
@onready var location_label: Label = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/LocationSlot/LocationStat/Text/Value
@onready var speed_buttons: Array[Button] = [
	$HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/SpeedSlot/Controls/PauseButton,
	$HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/SpeedSlot/Controls/PlayButton,
	$HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/SpeedSlot/Controls/FastButton,
]

func _ready() -> void:
	if not resized.is_connected(_update_content_margins):
		resized.connect(_update_content_margins)
	_update_content_margins()
	call_deferred("_update_content_margins")

	if Engine.is_editor_hint():
		return

	for i in speed_buttons.size():
		speed_buttons[i].pressed.connect(_on_speed_button_pressed.bind(i))
	set_speed(1)

func _update_content_margins() -> void:
	if not is_instance_valid(content_margin):
		return

	var horizontal_margin := int(round(size.x * HORIZONTAL_MARGIN_RATIO))
	content_margin.add_theme_constant_override("margin_left", horizontal_margin)
	content_margin.add_theme_constant_override("margin_right", horizontal_margin)

func set_values(day: int, gold: float, cargo: int, capacity: int, location: String, travel_days := 0) -> void:
	time_label.text = "Day %d" % day
	gold_label.text = "%06d" % int(round(gold))
	cargo_label.text = "%03d / %03d" % [cargo, capacity]
	if travel_days > 0:
		location_label.text = "%s (%d d)" % [location, travel_days]
	else:
		location_label.text = location

func set_speed(speed: int) -> void:
	for i in speed_buttons.size():
		speed_buttons[i].button_pressed = i == speed

func _on_speed_button_pressed(speed: int) -> void:
	set_speed(speed)
	speed_changed.emit(speed)

