extends RefCounted
class_name FinancePanelController

var _wm: Node
var _player_data: Node
var _finance_panel: PanelContainer = null
var _speed_before_finance: int = 1

func _init(world_map: Node) -> void:
	_wm = world_map
	_player_data = world_map.get_node("/root/PlayerData")

func toggle() -> void:
	if _finance_panel != null and is_instance_valid(_finance_panel):
		_close()
	else:
		_open()

func is_open() -> bool:
	return _finance_panel != null and is_instance_valid(_finance_panel)

func refresh() -> void:
	if not is_open():
		return
	_finance_panel.queue_free()
	_finance_panel = null
	_build()

func layout(side_left: float, top_bar_height: float, vp_x: float) -> void:
	if not is_open():
		return
	_finance_panel.offset_left = side_left + _wm.UI_GAP
	_finance_panel.offset_top = top_bar_height + _wm.UI_GAP
	_finance_panel.offset_right = vp_x - _wm.UI_GAP

func _open() -> void:
	_speed_before_finance = _wm.game_speed
	_wm._set_speed(0)
	_build()

func _close() -> void:
	if is_open():
		_finance_panel.queue_free()
	_finance_panel = null
	_wm._set_speed(_speed_before_finance)

func _build() -> void:
	var ui := _wm.get_node("UI")
	var panel := PanelContainer.new()
	panel.name = "FinancePanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	var vp: Vector2 = _wm.get_viewport_rect().size
	var side_left: float = vp.x - _wm._get_side_panel_width()
	panel.offset_left = side_left + _wm.UI_GAP
	panel.offset_top = _wm._get_top_bar_height() + _wm.UI_GAP
	panel.offset_right = vp.x - _wm.UI_GAP
	panel.offset_bottom = panel.offset_top + 340.0
	ui.add_child(panel)
	_finance_panel = panel

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Finance Summary"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(34, 28)
	close_btn.pressed.connect(toggle)
	header.add_child(close_btn)

	vbox.add_child(HSeparator.new())

	var summary: Dictionary = _player_data.get_finance_summary()
	_add_row(vbox, "Gold", MapUtils.format_gold(float(summary.get("gold", 0.0))))
	_add_row(vbox, "Debt", "%s (%d day%s)" % [
		MapUtils.format_gold(float(summary.get("debt", 0.0))),
		int(summary.get("debt_days", 0)),
		"" if int(summary.get("debt_days", 0)) == 1 else "s"
	])
	_add_row(vbox, "Daily upkeep", MapUtils.format_gold(float(summary.get("daily_upkeep", 0.0))))

	vbox.add_child(HSeparator.new())
	_add_section_title(vbox, "Upkeep Breakdown")
	_add_row(vbox, "Caravan", MapUtils.format_gold(float(summary.get("caravan_upkeep", 0.0))))
	_add_row(vbox, "Rank (%s)" % str(summary.get("rank", "")), MapUtils.format_gold(float(summary.get("rank_upkeep", 0.0))))
	_add_row(vbox, "Trading Posts (%d)" % int(summary.get("active_posts", 0)), MapUtils.format_gold(float(summary.get("trading_post_upkeep", 0.0))))

	vbox.add_child(HSeparator.new())
	_add_section_title(vbox, "Today")
	_add_bucket(vbox, summary.get("today", {}))

	vbox.add_child(HSeparator.new())
	_add_section_title(vbox, "Yesterday")
	_add_bucket(vbox, summary.get("yesterday", {}))

func _add_section_title(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	parent.add_child(label)

func _add_bucket(parent: VBoxContainer, bucket: Variant) -> void:
	var data: Dictionary = bucket if bucket is Dictionary else {}
	var income := float(data.get("income", 0.0))
	var expenses := float(data.get("expenses", 0.0))
	_add_row(parent, "Income", MapUtils.format_gold(income))
	_add_row(parent, "Expenses", MapUtils.format_gold(expenses))
	_add_row(parent, "Net", MapUtils.format_gold(income - expenses))
	_add_row(parent, "Debt paid", MapUtils.format_gold(float(data.get("debt_paid", 0.0))))
	_add_row(parent, "Upkeep paid", MapUtils.format_gold(float(data.get("upkeep_paid", 0.0))))
	_add_row(parent, "Unpaid upkeep", MapUtils.format_gold(float(data.get("upkeep_unpaid", 0.0))))

func _add_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.custom_minimum_size.x = 110
	row.add_child(value)
