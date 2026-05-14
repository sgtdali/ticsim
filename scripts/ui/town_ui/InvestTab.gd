extends TownTab

func build() -> void:
	var container = panel.get_node("ScrollContainer/InvestList")
	for child in container.get_children():
		child.queue_free()

	var prosperity := int(_economy.get_prosperity(town_name))
	var level := int(_economy.get_prosperity_level(town_name))
	var label := String(_economy.get_prosperity_label(town_name))

	# Header
	var title = Label.new()
	title.text = "Invest in %s" % town_name
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	container.add_child(title)

	var status = Label.new()
	status.text = "Status: %s (Level %d)  |  Prosperity: %d / %d" % [label, level, prosperity, _economy.PROSPERITY_MAX]
	status.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	container.add_child(status)

	var explain = Label.new()
	explain.text = "Invest gold into the town. Each %d gold raises prosperity by 1 point.\nA prosperous town produces more goods and pays better prices." % int(_economy.GOLD_PER_PROSPERITY_POINT)
	explain.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explain.add_theme_color_override("font_color", Color(0.76, 0.62, 0.36))
	container.add_child(explain)

	var multiplier := float(_economy.get_prosperity_multiplier(town_name))
	var production_bonus := int(round((multiplier - 1.0) * 100.0))
	var sell_bonus := int(round((multiplier - 1.0) * 30.0))
	var effects = Label.new()
	effects.text = "Current effects:\n  • Production: +%d%%\n  • Sell prices: +%d%%\n  • Demand: +%d%%" % [production_bonus, sell_bonus, production_bonus]
	effects.add_theme_color_override("font_color", Color(0.7, 0.95, 0.7))
	container.add_child(effects)

	container.add_child(HSeparator.new())

	var gold_lbl = Label.new()
	gold_lbl.text = "Your gold: %.1f" % _player.gold
	container.add_child(gold_lbl)

	if ui._invest_error != "":
		var err_lbl = Label.new()
		err_lbl.text = ui._invest_error
		err_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		container.add_child(err_lbl)

	var amounts := [50, 100, 250, 500]
	for amount in amounts:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var amount_lbl = Label.new()
		amount_lbl.text = "%d gold  →  +%d prosperity" % [amount, int(amount / _economy.GOLD_PER_PROSPERITY_POINT)]
		amount_lbl.custom_minimum_size.x = 240
		row.add_child(amount_lbl)

		var btn = Button.new()
		btn.text = "Invest"
		btn.disabled = (_player.gold < amount or prosperity >= _economy.PROSPERITY_MAX)
		ui.apply_primary_button_style(btn)
		btn.pressed.connect(_on_invest.bind(amount))
		row.add_child(btn)

		container.add_child(row)

func _on_invest(amount: int) -> void:
	ui._invest_error = ""
	var result = _economy.invest_gold(town_name, float(amount))
	if result is String:
		ui._invest_error = result
	else:
		var gained := int(result)
		if gained > 0:
			print("Invested %d gold in %s. +%d prosperity." % [amount, town_name, gained])
	build()
