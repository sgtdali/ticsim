@tool
extends Control

signal speed_changed(speed: int)
signal finance_requested

const HORIZONTAL_MARGIN_RATIO := 0.05

@onready var content_margin: MarginContainer = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin
@onready var gold_slot: Control = $HeaderTexture/MiddleRow/MiddleCenter/ContentMargin/Content/GoldSlot
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
	gold_slot.mouse_filter = Control.MOUSE_FILTER_STOP
	gold_slot.tooltip_text = "Open finance summary"
	gold_slot.gui_input.connect(_on_gold_slot_gui_input)
	set_speed(1)

func _update_content_margins() -> void:
	if not is_instance_valid(content_margin):
		return

	var horizontal_margin := int(round(size.x * HORIZONTAL_MARGIN_RATIO))
	content_margin.add_theme_constant_override("margin_left", horizontal_margin)
	content_margin.add_theme_constant_override("margin_right", horizontal_margin)

func set_values(day: int, gold: float, cargo: int, capacity: int, location: String, travel_days := 0) -> void:
	time_label.text = "Day %d" % day
	var player: Node = get_node_or_null("/root/PlayerData")
	if player != null and float(player.get("debt")) > 0.0:
		gold_label.text = "%04d D:%03d" % [int(round(gold)), int(ceil(float(player.get("debt"))))]
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	else:
		gold_label.text = "%06d" % int(round(gold))
		gold_label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
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

func _on_gold_slot_gui_input(event: InputEvent) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		finance_requested.emit()

func show_notification(message: String, color: Color = Color(1.0, 0.82, 0.36)) -> void:
	var notif := Label.new()
	notif.text = message
	notif.add_theme_color_override("font_color", color)
	notif.add_theme_font_size_override("font_size", 13)
	notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(notif)
	# 4 saniye sonra sil
	var timer := Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.timeout.connect(func(): notif.queue_free(); timer.queue_free())
	add_child(timer)
	timer.start()

