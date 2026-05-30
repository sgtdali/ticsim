extends RefCounted
class_name TraderLabelController

var _wm: Node
var _economy: Node
var _traders: Node

func _init(world_map: Node) -> void:
	_wm = world_map
	_economy = world_map.get_node("/root/EconomyManager")
	_traders = world_map.get_node_or_null("/root/TraderManager")

func build() -> void:
	if _traders == null:
		return
	var ui := _wm.get_node("UI")
	for trader_id in _traders.traders:
		var lbl := Label.new()
		lbl.name = "TraderLabel_%s" % trader_id
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
		ui.add_child(lbl)
	update()

func update() -> void:
	if _traders == null:
		return
	if _wm._active_town_scene != null and is_instance_valid(_wm._active_town_scene):
		var ui := _wm.get_node_or_null("UI")
		if ui:
			for child in ui.get_children():
				if child is CanvasItem and str(child.name).begins_with("TraderLabel_"):
					(child as CanvasItem).visible = false
		return

	for trader_id in _traders.traders:
		var lbl := _wm.get_node_or_null("UI/TraderLabel_%s" % trader_id) as Label
		if lbl == null:
			continue
		var trader: Dictionary = _traders.get_trader(trader_id)
		var trader_traveling: bool = _traders.is_traveling(trader_id)

		if trader_traveling:
			var from_town: String = str(trader.get("current_town", ""))
			var dest_town: String = str(trader.get("destination", ""))
			var from_pos: Vector2 = _wm._map_to_screen(_economy.towns.get(from_town, {}).get("position", Vector2.ZERO))
			var dest_pos: Vector2 = _wm._map_to_screen(_economy.towns.get(dest_town, {}).get("position", Vector2.ZERO))
			var days_done: float = float(trader.get("days_traveling", 0))
			var days_total: float = maxf(float(trader.get("travel_total_days", 1)), 1.0)
			var t: float = clamp(days_done / days_total, 0.0, 1.0)
			lbl.position = from_pos.lerp(dest_pos, t) + Vector2(8, -16)
			lbl.text = "» %s" % str(trader.get("name", ""))
			lbl.modulate = Color(1.0, 0.85, 0.4)
		else:
			var town_name: String = str(trader.get("current_town", ""))
			var town_pos: Vector2 = _wm._map_to_screen(_economy.towns.get(town_name, {}).get("position", Vector2.ZERO))
			var offset := Vector2(60, -8) * (["aldric", "mira", "torben"].find(trader_id) + 1) * 0.6
			lbl.position = town_pos + offset + Vector2(0, 20)
			lbl.text = "• %s" % str(trader.get("name", ""))
			lbl.modulate = Color(0.8, 0.65, 0.3)

		lbl.tooltip_text = _build_tooltip(trader, trader_id, trader_traveling)
		lbl.visible = true

func _build_tooltip(trader: Dictionary, trader_id: String, trader_traveling: bool) -> String:
	var lines: Array[String] = []
	lines.append(str(trader.get("name", "")))
	lines.append("─────────────────")

	match str(trader.get("type", "")):
		"aggressive": lines.append("Aggressive trader")
		"careful":    lines.append("Careful trader")
		"specialist": lines.append("Specialist (production goods)")

	var cargo_total: int = _traders.get_total_cargo(trader_id)
	var capacity: int = int(trader.get("cargo_capacity", 15))
	lines.append("Cargo: %d/%d" % [cargo_total, capacity])

	var inventory: Dictionary = trader.get("inventory", {})
	if inventory.is_empty():
		lines.append("(empty cargo)")
	else:
		for item in inventory:
			var qty: int = int(inventory[item])
			if qty > 0:
				lines.append("  %s x%d" % [str(item).capitalize(), qty])

	lines.append("─────────────────")
	if trader_traveling:
		var dest: String = str(trader.get("destination", ""))
		var days_left: int = int(trader.get("travel_total_days", 0)) - int(trader.get("days_traveling", 0))
		lines.append("Heading to %s (%d day(s))" % [dest, maxi(days_left, 0)])
	else:
		lines.append("In %s" % str(trader.get("current_town", "")))

	lines.append("Gold: %.0f" % float(trader.get("gold", 0.0)))
	return "\n".join(lines)

func on_trader_moved(trader_id: String, from_town: String, to_town: String) -> void:
	update()
	print("[Trader] %s: %s → %s" % [trader_id, from_town, to_town])

func on_trader_traded(trader_id: String, town_name: String, action: String, item: String, qty: int) -> void:
	print("[Trader] %s %s %dx %s in %s" % [trader_id, action, qty, item, town_name])
