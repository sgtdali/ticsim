extends RefCounted

var ui: Control
var panel: Control
var _economy: Node
var _player: Node
var _posts: Node

func _init(ui_node: Control, panel_node: Control) -> void:
	ui = ui_node
	panel = panel_node
	_economy = ui.get_node("/root/EconomyManager")
	_player = ui.get_node("/root/PlayerData")
	_posts = ui.get_node_or_null("/root/TradingPostManager")

func build() -> void:
	for child in panel.get_children():
		child.queue_free()
		
	if _posts == null:
		var lbl = Label.new()
		lbl.text = "Trading Post system not found."
		panel.add_child(lbl)
		return
		
	var town_name: String = ui.town_name
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 15)
	
	# Add some margin
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.add_child(vbox)
	panel.add_child(margin)
	
	if not _posts.has_post(town_name):
		_build_not_established(vbox, town_name)
	else:
		_build_established(vbox, town_name)

func _build_not_established(vbox: VBoxContainer, town_name: String) -> void:
	var title = Label.new()
	title.text = "Trading Post — Not established"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	var can_open_rank: bool = ui.get_node("/root/RankManager").can_open_trading_post()
	if not can_open_rank:
		var rank_lbl = Label.new()
		rank_lbl.text = "Trading Posts unlock at Merchant rank."
		rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		vbox.add_child(rank_lbl)
	
	var cost = Label.new()
	cost.text = "Cost to establish: %d gold" % _posts.POST_COST
	vbox.add_child(cost)
	
	var btn = Button.new()
	btn.text = "Open Trading Post"
	btn.disabled = _player.gold < _posts.POST_COST or not can_open_rank
	btn.pressed.connect(func():
		if _posts.establish_post(town_name):
			build()
			ui.get_node("TabBar/PostBtn").modulate = Color(0.3, 1.0, 0.3)
	)
	vbox.add_child(btn)

func _build_established(vbox: VBoxContainer, town_name: String) -> void:
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)
	
	_build_depot_section(content, town_name)
	content.add_child(HSeparator.new())
	_build_rules_section(content, town_name)

func _build_depot_section(vbox: VBoxContainer, town_name: String) -> void:
	var depot = _posts.get_depot(town_name)
	var total = _posts.get_depot_total(town_name)
	
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "DEPOT (%d/%d)" % [total, _posts.DEPOT_CAPACITY]
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	header.add_child(title)
	
	var dep_all_btn = Button.new()
	dep_all_btn.text = "Deposit All Cargo"
	dep_all_btn.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	dep_all_btn.pressed.connect(func():
		var items_to_move = _player.inventory.keys()
		for item in items_to_move:
			var qty = int(_player.inventory[item])
			if qty > 0:
				var space = _posts.DEPOT_CAPACITY - _posts.get_depot_total(town_name)
				var to_deposit = mini(qty, space)
				if to_deposit > 0:
					if _posts.add_to_depot(town_name, item, to_deposit):
						_player.remove_item(item, to_deposit)
		build()
	)
	header.add_child(dep_all_btn)
	vbox.add_child(header)
	
	var list = VBoxContainer.new()
	vbox.add_child(list)
	
	if depot.is_empty():
		var empty = Label.new()
		empty.text = "Depot is empty."
		empty.modulate = Color(0.6, 0.6, 0.6)
		list.add_child(empty)
	else:
		for item in depot.keys():
			var row = HBoxContainer.new()
			var lbl = Label.new()
			lbl.text = "%s x%d" % [str(item).capitalize(), int(depot[item])]
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(lbl)
			
			var take_btn = Button.new()
			take_btn.text = "Take"
			take_btn.pressed.connect(func():
				var free_cap = _player.get_free_capacity()
				if free_cap > 0:
					var to_take = mini(int(depot[item]), free_cap)
					if _posts.remove_from_depot(town_name, item, to_take):
						_player.add_item(item, to_take)
						build()
			)
			row.add_child(take_btn)
			list.add_child(row)

func _build_rules_section(vbox: VBoxContainer, town_name: String) -> void:
	var title = Label.new()
	title.text = "AUTO-RULES"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	vbox.add_child(title)
	
	var rules = _posts.get_rules(town_name)
	var list = VBoxContainer.new()
	vbox.add_child(list)
	
	if rules.is_empty():
		var empty = Label.new()
		empty.text = "No rules set."
		empty.modulate = Color(0.6, 0.6, 0.6)
		list.add_child(empty)
	else:
		for i in range(rules.size()):
			var rule = rules[i]
			var row = HBoxContainer.new()
			var desc = Label.new()
			var op = "<" if rule.get("type") == "buy" else ">"
			desc.text = "%s %s | price %s %.1fg | depot %s %d | max %d/day" % [
				str(rule.get("type")).to_upper(),
				str(rule.get("item")),
				op, float(rule.get("price_limit")),
				op, int(rule.get("depot_limit")),
				int(rule.get("daily_max"))
			]
			desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if not rule.get("enabled", true):
				desc.modulate = Color(0.5, 0.5, 0.5)
			row.add_child(desc)
			
			var toggle = Button.new()
			toggle.text = "Disable" if rule.get("enabled", true) else "Enable"
			toggle.pressed.connect(func():
				_posts.toggle_rule(town_name, i, not rule.get("enabled", true))
				build()
			)
			row.add_child(toggle)
			
			var del_btn = Button.new()
			del_btn.text = "Delete"
			del_btn.pressed.connect(func():
				_posts.remove_rule(town_name, i)
				build()
			)
			row.add_child(del_btn)
			list.add_child(row)
			
	_build_add_rule_form(vbox, town_name)

func _build_add_rule_form(vbox: VBoxContainer, town_name: String) -> void:
	var form = VBoxContainer.new()
	vbox.add_child(HSeparator.new())
	
	var header = Label.new()
	header.text = "Add New Rule"
	form.add_child(header)
	
	var h1 = HBoxContainer.new()
	var item_opt = OptionButton.new()
	for item in _economy.BASE_PRICES.keys():
		item_opt.add_item(item)
	h1.add_child(item_opt)
	
	var type_opt = OptionButton.new()
	type_opt.add_item("buy")
	type_opt.add_item("sell")
	h1.add_child(type_opt)
	form.add_child(h1)
	
	var h2 = HBoxContainer.new()
	var p_lbl = Label.new()
	p_lbl.text = "Price limit:"
	p_lbl.custom_minimum_size.x = 120
	h2.add_child(p_lbl)
	var price_spin = SpinBox.new()
	price_spin.max_value = 1000.0
	price_spin.step = 0.1
	price_spin.value = 5.0
	h2.add_child(price_spin)
	form.add_child(h2)
	
	var h3 = HBoxContainer.new()
	var m_lbl = Label.new()
	m_lbl.text = "Daily max qty:"
	m_lbl.custom_minimum_size.x = 120
	h3.add_child(m_lbl)
	var qty_spin = SpinBox.new()
	qty_spin.max_value = 50.0
	qty_spin.value = 5.0
	h3.add_child(qty_spin)
	form.add_child(h3)
	
	var h4 = HBoxContainer.new()
	var d_lbl = Label.new()
	d_lbl.text = "Depot threshold:"
	d_lbl.custom_minimum_size.x = 120
	h4.add_child(d_lbl)
	var depot_spin = SpinBox.new()
	depot_spin.max_value = 50.0
	depot_spin.value = 10.0
	h4.add_child(depot_spin)
	form.add_child(h4)
	
	var save_btn = Button.new()
	save_btn.text = "Save Rule"
	save_btn.pressed.connect(func():
		var item_name = item_opt.get_item_text(item_opt.selected)
		var t_type = type_opt.get_item_text(type_opt.selected)
		var rule = {
			"item": item_name,
			"type": t_type,
			"price_limit": float(price_spin.value),
			"daily_max": int(qty_spin.value),
			"depot_limit": int(depot_spin.value),
			"enabled": true
		}
		_posts.add_rule(town_name, rule)
		build()
	)
	form.add_child(save_btn)
	vbox.add_child(form)
