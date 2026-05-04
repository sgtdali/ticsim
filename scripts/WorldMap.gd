extends Node2D

var _player_data: Node
var _economy: Node

var is_traveling: bool = false
var travel_destination: String = ""
var travel_days_remaining: int = 0
var travel_total_days: int = 0
var travel_start_pos: Vector2   # screen space
var travel_end_pos: Vector2     # screen space

var town_buttons: Dictionary = {}

var game_speed: int = 1
const DAY_INTERVAL: float = 3.0

const MAP_W: float = 2816.0
const MAP_H: float = 1536.0

# City circle radius in screen pixels
const CITY_R: float = 14.0

# Calculated once in _setup_view
var _map_scale: float  = 1.0
var _map_offset: Vector2 = Vector2.ZERO

var _day_timer: Timer

signal town_selected(town_name: String)

# -----------------------------------------------

func _ready() -> void:
	_player_data = get_node("/root/PlayerData")
	_economy     = get_node("/root/EconomyManager")
	_player_data.current_town = "Ashford"

	_setup_view()
	_place_player()
	_build_town_buttons()
	_setup_day_timer()
	_setup_speed_buttons()
	_update_ui()

# Scale & position the map sprite to fill the viewport while keeping aspect ratio.
# WorldMap node itself stays at identity (position=0, scale=1).
# All other calculations use _map_to_screen() for explicit conversion.
func _setup_view() -> void:
	var vp: Vector2 = get_viewport_rect().size
	_map_scale  = min(vp.x / MAP_W, vp.y / MAP_H)
	_map_offset = (vp - Vector2(MAP_W, MAP_H) * _map_scale) * 0.5

	var map_sprite = get_node_or_null("MapSprite")
	if map_sprite:
		map_sprite.scale    = Vector2(_map_scale, _map_scale)
		map_sprite.position = _map_offset

# Map (world) coordinate → screen coordinate
func _map_to_screen(map_pos: Vector2) -> Vector2:
	return _map_offset + map_pos * _map_scale

func _setup_day_timer() -> void:
	_day_timer = Timer.new()
	_day_timer.wait_time = DAY_INTERVAL
	_day_timer.autostart = true
	_day_timer.timeout.connect(_on_day_tick)
	add_child(_day_timer)

func _setup_speed_buttons() -> void:
	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hbox.position = Vector2(10, -50)
	var labels = ["⏸", "▶ 1x", "⏩ 2x"]
	for i in 3:
		var btn := Button.new()
		btn.text = labels[i]
		btn.custom_minimum_size = Vector2(70, 36)
		btn.pressed.connect(_set_speed.bind(i))
		hbox.add_child(btn)
	get_node("UI").add_child(hbox)

func _set_speed(speed: int) -> void:
	game_speed = speed
	if speed == 0:
		_day_timer.paused = true
	else:
		_day_timer.paused = false
		_day_timer.wait_time = DAY_INTERVAL / float(speed)

# -----------------------------------------------
# City markers + roads drawn in SCREEN space.
# WorldMap has no transform so local space == screen space.

func _draw() -> void:
	var towns = _economy.towns
	var town_names = towns.keys()

	# Roads
	for i in range(town_names.size()):
		for j in range(i + 1, town_names.size()):
			var pa = _map_to_screen(towns[town_names[i]].get("position", Vector2.ZERO))
			var pb = _map_to_screen(towns[town_names[j]].get("position", Vector2.ZERO))
			draw_line(pa, pb, Color(0.55, 0.45, 0.25, 0.7), 3.0)

	# City circles
	for town_name in town_names:
		var sp = _map_to_screen(towns[town_name].get("position", Vector2.ZERO))
		var is_current: bool = (town_name == _player_data.current_town)
		var is_dest: bool    = (town_name == travel_destination)

		# Shadow ring
		draw_circle(sp, CITY_R + 5.0, Color(0.0, 0.0, 0.0, 0.4))
		# Fill
		var col: Color
		if is_current:
			col = Color(0.2, 0.85, 0.2)
		elif is_dest:
			col = Color(0.9, 0.65, 0.1)
		else:
			col = Color(0.85, 0.75, 0.25)
		draw_circle(sp, CITY_R, col)
		# Dark border ring (drawn as slightly smaller shadow-colored disk on top perimeter)
		draw_arc(sp, CITY_R, 0.0, TAU, 32, Color(0.1, 0.1, 0.1, 0.9), 2.0)

# -----------------------------------------------

func _process(delta: float) -> void:
	queue_redraw()
	if not is_traveling or game_speed == 0:
		return
	var player = get_node("Player")
	var total_dist = travel_start_pos.distance_to(travel_end_pos)
	if total_dist < 1.0:
		return
	var speed_px = total_dist * float(game_speed) / (float(travel_total_days) * DAY_INTERVAL)
	player.position = player.position.move_toward(travel_end_pos, speed_px * delta)

func _on_day_tick() -> void:
	_economy.advance_day()
	_player_data.advance_day()
	if is_traveling:
		travel_days_remaining -= 1
		if travel_days_remaining <= 0:
			get_node("Player").position = travel_end_pos
			_arrive()
			return
	_update_ui()

# -----------------------------------------------

func _build_town_buttons() -> void:
	var ui_layer = get_node("UI")
	for town_name in _economy.towns:
		var sp: Vector2 = _map_to_screen(_economy.towns[town_name].get("position", Vector2.ZERO))
		var btn := Button.new()
		btn.text = town_name
		btn.custom_minimum_size = Vector2(120, 36)
		btn.position = sp - Vector2(60, CITY_R + 44)  # above city circle
		btn.pressed.connect(_on_town_pressed.bind(town_name))
		ui_layer.add_child(btn)
		town_buttons[town_name] = btn
	_refresh_buttons()

func _place_player() -> void:
	var map_pos: Vector2 = _economy.towns.get(_player_data.current_town, {}).get("position", Vector2.ZERO)
	get_node("Player").position = _map_to_screen(map_pos)

func _on_town_pressed(town_name: String) -> void:
	if is_traveling:
		return
	if town_name == _player_data.current_town:
		_open_town(town_name)
		return

	is_traveling = true
	travel_destination    = town_name
	travel_start_pos      = get_node("Player").position
	travel_end_pos        = _map_to_screen(_economy.towns[town_name].get("position", Vector2.ZERO))
	travel_total_days     = _calc_travel_days(town_name)
	travel_days_remaining = travel_total_days

	_refresh_buttons()
	_update_ui()

func _calc_travel_days(town_name: String) -> int:
	var from: Vector2 = _economy.towns[_player_data.current_town].get("position", Vector2.ZERO)
	var to: Vector2   = _economy.towns[town_name].get("position", Vector2.ZERO)
	return max(1, int(from.distance_to(to) / 200.0))

func _arrive() -> void:
	is_traveling = false
	_player_data.current_town = travel_destination
	travel_destination = ""
	travel_days_remaining = 0
	travel_total_days = 0
	_refresh_buttons()
	_update_ui()
	_open_town(_player_data.current_town)

func _open_town(town_name: String) -> void:
	_day_timer.paused = true
	var town_ui = preload("res://scenes/TownUI.tscn").instantiate()
	town_ui.town_name = town_name
	get_node("UI").add_child(town_ui)
	town_ui.closed.connect(_on_town_ui_closed)

func _on_town_ui_closed() -> void:
	if game_speed > 0:
		_day_timer.paused = false
	_update_ui()
	_refresh_buttons()

func _refresh_buttons() -> void:
	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		if is_traveling:
			btn.modulate = Color(0.55, 0.55, 0.55)
		elif town_name == _player_data.current_town:
			btn.modulate = Color(0.3, 1.0, 0.3)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)

func _update_ui() -> void:
	var day_lbl    = get_node_or_null("UI/InfoPanel/VBox/DayLabel")
	var gold_lbl   = get_node_or_null("UI/InfoPanel/VBox/GoldLabel")
	var loc_lbl    = get_node_or_null("UI/InfoPanel/VBox/LocationLabel")
	var travel_lbl = get_node_or_null("UI/InfoPanel/VBox/TravelLabel")

	if day_lbl:  day_lbl.text  = "Day: %d"      % _player_data.current_day
	if gold_lbl: gold_lbl.text = "Gold: %.1f"   % _player_data.gold
	if loc_lbl:  loc_lbl.text  = "Location: %s" % _player_data.current_town
	if travel_lbl:
		if is_traveling:
			travel_lbl.text = "→ %s (%d day(s))" % [travel_destination, travel_days_remaining]
		else:
			travel_lbl.text = ""
