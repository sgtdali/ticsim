extends TownTab

func build() -> void:
	var container = panel.get_node("ScrollContainer/UpgradeList")
	for child in container.get_children():
		child.queue_free()

	# Mevcut durum
	var title = Label.new()
	title.text = "Caravan Upgrade"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	container.add_child(title)

	var current = Label.new()
	current.text = "Current: %s  |  Cargo capacity: %d" % [
		_player.get_upgrade_name(),
		_player.caravan_capacity,
	]
	current.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	container.add_child(current)

	container.add_child(HSeparator.new())

	# Upgrade seçenekleri
	var names: Array = _player.UPGRADE_NAMES
	var capacities: Array = _player.UPGRADE_CAPACITIES
	var costs: Array = _player.UPGRADE_COSTS

	var can_upgrade_rank: bool = ui.get_node("/root/RankManager").can_upgrade_caravan()
	if not can_upgrade_rank:
		var rank_lbl = Label.new()
		rank_lbl.text = "Caravan upgrades unlock at Trader rank."
		rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		container.add_child(rank_lbl)

	for i in range(names.size()):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		var info = Label.new()
		var is_current = (i == _player.caravan_upgrade_level)
		var is_owned = (i < _player.caravan_upgrade_level)
		var prefix = ""
		if is_current:
			prefix = "▶ "
		elif is_owned:
			prefix = "✓ "

		info.text = "%s%s — %d cargo" % [prefix, names[i], capacities[i]]
		info.custom_minimum_size.x = 220
		if is_current:
			info.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		elif is_owned:
			info.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row.add_child(info)

		if i > _player.caravan_upgrade_level:
			var cost_lbl = Label.new()
			cost_lbl.text = "%d gold" % costs[i]
			cost_lbl.custom_minimum_size.x = 80
			row.add_child(cost_lbl)

			if i == _player.caravan_upgrade_level + 1:
				var btn = Button.new()
				btn.text = "Upgrade"
				btn.disabled = not _player.can_upgrade_caravan() or not can_upgrade_rank
				ui.apply_primary_button_style(btn)
				btn.pressed.connect(_on_upgrade_caravan)
				row.add_child(btn)

				if not _player.can_upgrade_caravan():
					var need = Label.new()
					var shortage = int(costs[i]) - int(_player.gold)
					if shortage > 0:
						need.text = "(need %d more gold)" % shortage
						need.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
						row.add_child(need)

		container.add_child(row)

	# Gold göster
	container.add_child(HSeparator.new())
	var gold_lbl = Label.new()
	gold_lbl.text = "Your gold: %.1f" % _player.gold
	container.add_child(gold_lbl)

func _on_upgrade_caravan() -> void:
	var success: bool = _player.upgrade_caravan()
	if success:
		print("Caravan upgraded to: %s (%d cargo)" % [_player.get_upgrade_name(), _player.caravan_capacity])
	build()
