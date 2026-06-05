extends TownTab

const CLOSED_ROW_BG = preload("res://assets/ui/market/market_closed_row_bg_style.tres")
const OPENED_ROW_BG = preload("res://assets/ui/market/market_opened_row_bg_style.tres")
const TAB_SELECTED = preload("res://assets/ui/market/market_top_section_button/market_tab_selected_style.tres")
const TAB_UNSELECTED = preload("res://assets/ui/market/market_top_section_button/market_tab_unselected_style.tres")

var _masters: Node
var _inner_tab: String = "hiring"
var _expanded_candidate_id: String = ""

# Cache UI references
var _hiring_btn: Button
var _roster_btn: Button
var _rumors_btn: Button
var _town_name_lbl: Label
var _pop_lbl: Label
var _rep_lbl: Label
var _avail_lbl: Label
var _slots_lbl: Label
var _header_cells: Control
var _header_panel: PanelContainer
var _content_list: Control
var _grid: Control

func setup() -> void:
	_masters = ui.get_node_or_null("/root/CaravanMasterManager")
	
	# Grab nodes from the TavernPanel scene tree
	_hiring_btn = panel.get_node("TavernFrame/TavernRoot/TabRow/HiringTabBtn") as Button
	_roster_btn = panel.get_node("TavernFrame/TavernRoot/TabRow/RosterTabBtn") as Button
	_rumors_btn = panel.get_node("TavernFrame/TavernRoot/TabRow/RumorsTabBtn") as Button
	
	_town_name_lbl = panel.get_node("TavernFrame/TavernRoot/TownBanner/BannerHBox/LeftInfo/TownNameLabel") as Label
	_pop_lbl = panel.get_node("TavernFrame/TavernRoot/TownBanner/BannerHBox/LeftInfo/MetaHBox/PopLabel") as Label
	_rep_lbl = panel.get_node("TavernFrame/TavernRoot/TownBanner/BannerHBox/LeftInfo/MetaHBox/RepLabel") as Label
	_avail_lbl = panel.get_node("TavernFrame/TavernRoot/TownBanner/BannerHBox/RightInfo/AvailLabel") as Label
	_slots_lbl = panel.get_node("TavernFrame/TavernRoot/TownBanner/BannerHBox/RightInfo/SlotsLabel") as Label
	
	_header_panel = panel.get_node("TavernFrame/TavernRoot/ColumnsHBox/LeftColumn/TableHeader") as PanelContainer
	_header_cells = panel.get_node("TavernFrame/TavernRoot/ColumnsHBox/LeftColumn/TableHeader/HeaderCells") as Control
	_content_list = panel.get_node("TavernFrame/TavernRoot/ColumnsHBox/LeftColumn/Scroll/ContentList") as Control
	_grid = panel.get_node("TavernFrame/TavernRoot/ColumnsHBox/RightColumn/SidebarMargin/SidebarVBox/Grid") as Control
	
	# Connect static buttons
	_hiring_btn.pressed.connect(func():
		_inner_tab = "hiring"
		_auto_expand_first()
		build()
	)
	_roster_btn.pressed.connect(func():
		_inner_tab = "roster"
		build()
	)
	_rumors_btn.pressed.connect(func():
		_inner_tab = "rumors"
		build()
	)
	
	var manage_btn := panel.get_node("TavernFrame/TavernRoot/ColumnsHBox/RightColumn/SidebarMargin/SidebarVBox/ManageBtn") as Button
	manage_btn.pressed.connect(func():
		ui._on_close()
	)

	var close_btn := panel.get_node_or_null("CloseButton") as TextureButton
	if close_btn != null:
		close_btn.pressed.connect(func():
			ui._on_close()
		)

func build() -> void:
	if _masters == null:
		return

	# 1. Update Tab Buttons styling
	_update_tab_styles()

	# 2. Update Header Banner values
	_update_banner()

	# 3. Populate Sidebar Grid
	_update_sidebar()

	# 4. Populate Left Column Content based on active inner tab
	_clear_container(_content_list)
	
	if _inner_tab == "hiring":
		_build_hiring_view()
	elif _inner_tab == "roster":
		_build_roster_view()
	elif _inner_tab == "rumors":
		_build_rumors_view()

# --- Tab Buttons Styling ---
func _update_tab_styles() -> void:
	_hiring_btn.button_pressed = (_inner_tab == "hiring")
	_roster_btn.button_pressed = (_inner_tab == "roster")
	_rumors_btn.button_pressed = (_inner_tab == "rumors")

	_apply_tab_style(_hiring_btn, _inner_tab == "hiring")
	_apply_tab_style(_roster_btn, _inner_tab == "roster")
	_apply_tab_style(_rumors_btn, _inner_tab == "rumors")

func _apply_tab_style(button: Button, active: bool) -> void:
	if active:
		button.add_theme_stylebox_override("normal", TAB_SELECTED)
		button.add_theme_stylebox_override("hover", TAB_SELECTED)
		button.add_theme_stylebox_override("pressed", TAB_SELECTED)
		button.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	else:
		button.add_theme_stylebox_override("normal", TAB_UNSELECTED)
		button.add_theme_stylebox_override("hover", TAB_SELECTED)
		button.add_theme_stylebox_override("pressed", TAB_SELECTED)
		button.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))

# --- Banner values ---
func _update_banner() -> void:
	_town_name_lbl.text = town_name
	
	var town_dict: Dictionary = _economy.get_town(town_name)
	var population: int = int(town_dict.get("population", 0))
	_pop_lbl.text = "👥 %d" % population

	var faction_name: String = String(town_dict.get("faction", ""))
	var rep: float = float(_player.get_faction_rep(faction_name))
	var faction_manager := ui.get_node_or_null("/root/FactionManager")
	_rep_lbl.text = "🛡️ %s" % (faction_manager.get_relation_description(rep) if faction_manager else "Reputable")

	var candidates: Array = _masters.town_candidates.get(town_name, [])
	_avail_lbl.text = "Available Masters: %d" % candidates.size()

	var active_count: int = _masters.get_active_master_count()
	var master_cap: int = _masters.get_master_cap()
	_slots_lbl.text = "Master Slots: %d / %d" % [active_count, master_cap]
	if active_count >= master_cap:
		_slots_lbl.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	else:
		_slots_lbl.add_theme_color_override("font_color", Color(0.5, 0.9, 0.4))

# --- Sidebar ---
func _update_sidebar() -> void:
	_clear_container(_grid)
	
	var active_count: int = _masters.get_active_master_count()
	var master_cap: int = _masters.get_master_cap()

	var active_routes := 0
	for master_id in _masters.masters:
		var route = _masters.get_route(master_id)
		if route.get("active", false):
			active_routes += 1

	var idle_masters = active_count - active_routes
	var total_wages = _masters.get_total_daily_wage()
	var candidates: Array = _masters.town_candidates.get(town_name, [])

	_add_sidebar_row(_grid, "👥 Hired Masters", "%d / %d" % [active_count, master_cap])
	_add_sidebar_row(_grid, "🧭 Active Routes", "%d" % active_routes)
	_add_sidebar_row(_grid, "💤 Idle Masters", "%d" % idle_masters)
	_add_sidebar_row(_grid, "🪙 Daily Wages", "%d g" % total_wages)
	_add_sidebar_row(_grid, "📍 Town Availability", "%d candidates" % candidates.size())

func _add_sidebar_row(parent: Control, label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color(0.75, 0.7, 0.65))
	lbl.add_theme_font_size_override("font_size", 12)
	row.add_child(lbl)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var val := Label.new()
	val.text = value_text
	val.add_theme_color_override("font_color", Color(0.9, 0.85, 0.78))
	val.add_theme_font_size_override("font_size", 12)
	row.add_child(val)

# --- Hiring Tab View ---
func _build_hiring_view() -> void:
	_header_panel.visible = true

	# Build headers if they are empty
	if _header_cells.get_child_count() == 0:
		_add_header_cell(_header_cells, "Candidate", 0.22)
		_add_header_cell(_header_cells, "Archetype", 0.20)
		_add_header_cell(_header_cells, "Daily Wage", 0.16)
		_add_header_cell(_header_cells, "Hire Fee", 0.16)
		_add_header_cell(_header_cells, "Focus", 0.14)
		_add_header_cell(_header_cells, "Status", 0.12)

	var candidates: Array = _masters.town_candidates.get(town_name, [])
	if candidates.is_empty():
		_header_panel.visible = false
		var empty_lbl := Label.new()
		empty_lbl.text = "No Caravan Masters are available in this tavern today.\nCheck another city or return later."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.custom_minimum_size = Vector2(0, 160)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.48))
		empty_lbl.add_theme_font_size_override("font_size", 14)
		_content_list.add_child(empty_lbl)
		return

	# Ensure a valid expanded candidate exists
	var valid_expanded := false
	for c in candidates:
		if c.id == _expanded_candidate_id:
			valid_expanded = true
			break
	if not valid_expanded:
		_expanded_candidate_id = candidates[0].id

	for candidate in candidates:
		if candidate.id == _expanded_candidate_id:
			_build_expanded_row(_content_list, candidate)
		else:
			_build_collapsed_row(_content_list, candidate)

func _add_header_cell(parent: HBoxContainer, text: String, ratio: float) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_stretch_ratio = ratio
	lbl.add_theme_color_override("font_color", Color(0.6, 0.52, 0.42))
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lbl)

func _build_collapsed_row(parent: VBoxContainer, candidate: CaravanMaster) -> void:
	var row_panel := PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0, 48)
	row_panel.add_theme_stylebox_override("panel", CLOSED_ROW_BG)
	parent.add_child(row_panel)

	var row_hbox := HBoxContainer.new()
	row_hbox.add_theme_constant_override("separation", 8)
	row_panel.add_child(row_hbox)

	var expand_btn := Button.new()
	expand_btn.text = "▼"
	expand_btn.custom_minimum_size = Vector2(24, 24)
	expand_btn.flat = true
	expand_btn.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
	expand_btn.pressed.connect(func():
		_expanded_candidate_id = candidate.id
		build()
	)
	row_hbox.add_child(expand_btn)

	var name_lbl := Label.new()
	name_lbl.text = candidate.display_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.size_flags_stretch_ratio = 0.22
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.82, 0.7))
	name_lbl.add_theme_font_size_override("font_size", 13)
	row_hbox.add_child(name_lbl)

	var arch_lbl := Label.new()
	arch_lbl.text = _get_archetype_name(candidate.display_name)
	arch_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arch_lbl.size_flags_stretch_ratio = 0.20
	arch_lbl.add_theme_color_override("font_color", Color(0.7, 0.62, 0.5))
	arch_lbl.add_theme_font_size_override("font_size", 13)
	arch_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_hbox.add_child(arch_lbl)

	var wage_lbl := Label.new()
	wage_lbl.text = "%d g" % candidate.daily_wage
	wage_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wage_lbl.size_flags_stretch_ratio = 0.16
	wage_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.65))
	wage_lbl.add_theme_font_size_override("font_size", 13)
	wage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_hbox.add_child(wage_lbl)

	var fee_lbl := Label.new()
	fee_lbl.text = "%d g" % candidate.hire_cost
	fee_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fee_lbl.size_flags_stretch_ratio = 0.16
	fee_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	fee_lbl.add_theme_font_size_override("font_size", 13)
	fee_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_hbox.add_child(fee_lbl)

	var focus_lbl := Label.new()
	focus_lbl.text = _get_focus_stat(candidate)
	focus_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	focus_lbl.size_flags_stretch_ratio = 0.14
	focus_lbl.add_theme_color_override("font_color", Color(0.85, 0.7, 0.5))
	focus_lbl.add_theme_font_size_override("font_size", 13)
	focus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_hbox.add_child(focus_lbl)

	var status_lbl := Label.new()
	status_lbl.text = "Available"
	status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_lbl.size_flags_stretch_ratio = 0.12
	status_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.3))
	status_lbl.add_theme_font_size_override("font_size", 13)
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_hbox.add_child(status_lbl)

	row_panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_expanded_candidate_id = candidate.id
			build()
	)

func _build_expanded_row(parent: VBoxContainer, candidate: CaravanMaster) -> void:
	var card_panel := PanelContainer.new()
	card_panel.add_theme_stylebox_override("panel", OPENED_ROW_BG)
	parent.add_child(card_panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	card_panel.add_child(hbox)

	var collapse_btn := Button.new()
	collapse_btn.text = "▲"
	collapse_btn.custom_minimum_size = Vector2(24, 24)
	collapse_btn.flat = true
	collapse_btn.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
	collapse_btn.pressed.connect(func():
		_expanded_candidate_id = ""
		build()
	)
	hbox.add_child(collapse_btn)

	# 1. Portrait Frame (Left)
	var port_frame := PanelContainer.new()
	var f_style := StyleBoxFlat.new()
	f_style.bg_color = Color(0.12, 0.09, 0.07, 0.95)
	f_style.border_width_left = 2
	f_style.border_width_right = 2
	f_style.border_width_top = 2
	f_style.border_width_bottom = 2
	f_style.border_color = Color(0.72, 0.58, 0.36, 0.9)
	f_style.corner_radius_top_left = 6
	f_style.corner_radius_top_right = 6
	f_style.corner_radius_bottom_left = 6
	f_style.corner_radius_bottom_right = 6
	f_style.content_margin_left = 8
	f_style.content_margin_right = 8
	f_style.content_margin_top = 8
	f_style.content_margin_bottom = 8
	port_frame.add_theme_stylebox_override("panel", f_style)
	port_frame.custom_minimum_size = Vector2(100, 110)
	port_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(port_frame)

	var avatar_lbl := Label.new()
	avatar_lbl.text = "👤"
	avatar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar_lbl.add_theme_font_size_override("font_size", 44)
	port_frame.add_child(avatar_lbl)

	# 2. Main Info & Stats (Middle Column)
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 6)
	hbox.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = "%s" % candidate.display_name
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	
	var sub_lbl := Label.new()
	sub_lbl.text = _get_archetype_name(candidate.display_name)
	sub_lbl.add_theme_color_override("font_color", Color(0.72, 0.58, 0.36))
	sub_lbl.add_theme_font_size_override("font_size", 12)
	
	var header_vbox := VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 1)
	header_vbox.add_child(name_lbl)
	header_vbox.add_child(sub_lbl)
	info_vbox.add_child(header_vbox)

	var flavor_lbl := Label.new()
	flavor_lbl.text = _get_archetype_flavor(candidate.display_name)
	flavor_lbl.add_theme_color_override("font_color", Color(0.65, 0.58, 0.5))
	flavor_lbl.add_theme_font_size_override("font_size", 12)
	flavor_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(flavor_lbl)

	# Stats Row (Mockup Icons + Stats)
	var stats_hbox := HBoxContainer.new()
	stats_hbox.add_theme_constant_override("separation", 16)
	info_vbox.add_child(stats_hbox)

	var speed_pct = int(round(100.0 / candidate.get_travel_multiplier()))
	var safety_pct = int(round(candidate.courage * 4))
	var negotiation_pct = int(round(candidate.bargaining * 4))

	_add_detail_stat(stats_hbox, "📦 Cargo Cap", "+%d" % candidate.get_capacity())
	_add_detail_stat(stats_hbox, "🧭 Speed", "%d%%" % speed_pct)
	_add_detail_stat(stats_hbox, "🛡️ Safety", "+%d%%" % safety_pct)
	_add_detail_stat(stats_hbox, "🤝 Negotiation", "+%d%%" % negotiation_pct)

	# Trait Tags (Pills)
	var traits_hbox := HBoxContainer.new()
	traits_hbox.add_theme_constant_override("separation", 6)
	info_vbox.add_child(traits_hbox)

	var traits_list := _get_archetype_traits(candidate.display_name)
	for t_name in traits_list:
		var pill := PanelContainer.new()
		var p_style := StyleBoxFlat.new()
		p_style.bg_color = Color(0.2, 0.16, 0.12, 0.8)
		p_style.border_width_left = 1
		p_style.border_width_right = 1
		p_style.border_width_top = 1
		p_style.border_width_bottom = 1
		p_style.border_color = Color(0.5, 0.4, 0.28)
		p_style.content_margin_left = 8
		p_style.content_margin_right = 8
		p_style.content_margin_top = 2
		p_style.content_margin_bottom = 2
		p_style.corner_radius_top_left = 3
		p_style.corner_radius_top_right = 3
		p_style.corner_radius_bottom_left = 3
		p_style.corner_radius_bottom_right = 3
		pill.add_theme_stylebox_override("panel", p_style)
		traits_hbox.add_child(pill)

		var pill_lbl := Label.new()
		pill_lbl.text = t_name
		pill_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
		pill_lbl.add_theme_font_size_override("font_size", 10)
		pill.add_child(pill_lbl)

	var loc_lbl := Label.new()
	loc_lbl.text = "📍 Available to hire in %s today" % town_name
	loc_lbl.add_theme_color_override("font_color", Color(0.55, 0.5, 0.42))
	loc_lbl.add_theme_font_size_override("font_size", 11)
	info_vbox.add_child(loc_lbl)

	# 3. Cost & Action Buttons (Right Column)
	var action_vbox := VBoxContainer.new()
	action_vbox.custom_minimum_size = Vector2(110, 0)
	action_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	action_vbox.add_theme_constant_override("separation", 8)
	hbox.add_child(action_vbox)

	var active_count: int = _masters.get_active_master_count()
	var master_cap: int = _masters.get_master_cap()
	var free_slots = master_cap - active_count
	var slot_lbl := Label.new()
	slot_lbl.text = "%d slot free" % free_slots if free_slots > 0 else "0 slots free"
	slot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.4) if free_slots > 0 else Color(0.9, 0.3, 0.2))
	slot_lbl.add_theme_font_size_override("font_size", 12)
	action_vbox.add_child(slot_lbl)

	var cost_vbox := VBoxContainer.new()
	cost_vbox.add_theme_constant_override("separation", 1)
	action_vbox.add_child(cost_vbox)

	var fee_lbl := Label.new()
	fee_lbl.text = "%d 🟡" % candidate.hire_cost
	fee_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fee_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	fee_lbl.add_theme_font_size_override("font_size", 18)
	cost_vbox.add_child(fee_lbl)

	var wage_lbl := Label.new()
	wage_lbl.text = "%d per day" % candidate.daily_wage
	wage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wage_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.58))
	wage_lbl.add_theme_font_size_override("font_size", 11)
	cost_vbox.add_child(wage_lbl)

	var hire_btn := Button.new()
	hire_btn.text = "Hire"
	hire_btn.custom_minimum_size = Vector2(100, 32)
	
	var can_hire: bool = _masters.can_hire_master() and _player.gold >= candidate.hire_cost and not _player.has_debt()
	hire_btn.disabled = not can_hire
	
	if can_hire:
		ui.apply_primary_button_style(hire_btn)
	else:
		ui.apply_secondary_button_style(hire_btn)
		
	hire_btn.pressed.connect(func():
		var success: bool = _masters.hire_candidate(town_name, candidate.id)
		if success:
			var top_bar = ui.get_node_or_null("/root/WorldMap/UI/TopBar")
			if top_bar == null:
				top_bar = ui.get_tree().root.find_child("TopBar", true, false)
			if top_bar and top_bar.has_method("show_notification"):
				top_bar.call("show_notification", "Hired: %s!" % candidate.display_name, Color(0.4, 0.9, 0.4))
			build()
	)
	action_vbox.add_child(hire_btn)

	var inspect_btn := Button.new()
	inspect_btn.text = "Collapse"
	inspect_btn.custom_minimum_size = Vector2(100, 30)
	ui.apply_secondary_button_style(inspect_btn)
	inspect_btn.pressed.connect(func():
		_expanded_candidate_id = ""
		build()
	)
	action_vbox.add_child(inspect_btn)

func _add_detail_stat(parent: Control, label_text: String, val_text: String) -> void:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 4)
	parent.add_child(cell)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.58))
	lbl.add_theme_font_size_override("font_size", 12)
	cell.add_child(lbl)

	var val := Label.new()
	val.text = val_text
	val.add_theme_color_override("font_color", Color(0.9, 0.82, 0.7))
	val.add_theme_font_size_override("font_size", 12)
	cell.add_child(val)

# --- Roster View ---
func _build_roster_view() -> void:
	_header_panel.visible = false
	
	if _masters.masters.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "You do not have any hired Caravan Masters.\nGo to the Hiring tab to find and hire candidates."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.custom_minimum_size = Vector2(0, 160)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.48))
		empty_lbl.add_theme_font_size_override("font_size", 14)
		_content_list.add_child(empty_lbl)
		return

	for master_id in _masters.masters.keys():
		var master: CaravanMaster = _masters.masters[master_id]
		var route: Dictionary = _masters.get_route(master_id)
		
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", OPENED_ROW_BG)
		_content_list.add_child(card)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		card.add_child(hbox)

		var port_frame := PanelContainer.new()
		var f_style := StyleBoxFlat.new()
		f_style.bg_color = Color(0.12, 0.09, 0.07, 0.95)
		f_style.border_width_left = 2
		f_style.border_width_right = 2
		f_style.border_width_top = 2
		f_style.border_width_bottom = 2
		f_style.border_color = Color(0.62, 0.52, 0.36, 0.9)
		f_style.corner_radius_top_left = 4
		f_style.corner_radius_top_right = 4
		f_style.corner_radius_bottom_left = 4
		f_style.corner_radius_bottom_right = 4
		port_frame.add_theme_stylebox_override("panel", f_style)
		port_frame.custom_minimum_size = Vector2(80, 90)
		port_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(port_frame)

		var avatar_lbl := Label.new()
		avatar_lbl.text = "👤"
		avatar_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		avatar_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		avatar_lbl.add_theme_font_size_override("font_size", 34)
		port_frame.add_child(avatar_lbl)

		var detail_vbox := VBoxContainer.new()
		detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail_vbox.add_theme_constant_override("separation", 4)
		hbox.add_child(detail_vbox)

		var name_lbl := Label.new()
		name_lbl.text = "%s (Level %d)" % [master.display_name, master.level]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		detail_vbox.add_child(name_lbl)

		var stops: Array = route.get("stops", [])
		var stop_names: Array[String] = []
		for stop in stops:
			stop_names.append(str(stop.get("town_name", "")))
		var route_lbl := Label.new()
		route_lbl.text = "Route: %s" % (" ➔ ".join(stop_names) if not stop_names.is_empty() else "No Active Route")
		route_lbl.add_theme_color_override("font_color", Color(0.85, 0.75, 0.6))
		route_lbl.add_theme_font_size_override("font_size", 12)
		detail_vbox.add_child(route_lbl)

		var status_lbl := Label.new()
		var loc = _masters.get_master_location(master_id)
		status_lbl.text = "Status: %s" % ("Idle" if loc == "idle" else "Traveling %s" % loc)
		status_lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 0.4) if loc == "idle" else Color(0.4, 0.7, 0.9))
		status_lbl.add_theme_font_size_override("font_size", 12)
		detail_vbox.add_child(status_lbl)

		var wage_lbl := Label.new()
		wage_lbl.text = "Wage: %d g/day" % master.daily_wage
		wage_lbl.add_theme_color_override("font_color", Color(0.65, 0.6, 0.52))
		wage_lbl.add_theme_font_size_override("font_size", 12)
		detail_vbox.add_child(wage_lbl)

		var act_vbox := VBoxContainer.new()
		act_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(act_vbox)

		var fire_btn := Button.new()
		fire_btn.text = "Fire Master"
		fire_btn.custom_minimum_size = Vector2(110, 32)
		ui.apply_secondary_button_style(fire_btn)
		fire_btn.pressed.connect(func():
			_masters.fire_master(master_id)
			build()
		)
		act_vbox.add_child(fire_btn)

# --- Rumors View ---
func _build_rumors_view() -> void:
	_header_panel.visible = false

	var rumors_list := [
		{
			"town": "Ashford",
			"rumor": "Local farmers report an excellent wheat harvest this season. Wheat prices are low, buy now!",
			"tag": "Wheat Supply Up"
		},
		{
			"town": "Ironmere",
			"rumor": "High demand for iron bar has sparked a production rush. Iron ore demand is rising rapidly!",
			"tag": "Ore Demand Spike"
		},
		{
			"town": "Stonebridge",
			"rumor": "Grapes are in short supply due to dry seasons. Wine production will be slow for some weeks.",
			"tag": "Wine Shortage Warning"
		}
	]

	var title := Label.new()
	title.text = "Tavern Gossip & Whispers"
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	_content_list.add_child(title)

	for rumor in rumors_list:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", CLOSED_ROW_BG)
		_content_list.add_child(card)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		card.add_child(vbox)

		var header_hbox := HBoxContainer.new()
		vbox.add_child(header_hbox)

		var town_lbl := Label.new()
		town_lbl.text = "📍 %s Gossip" % rumor["town"]
		town_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
		town_lbl.add_theme_font_size_override("font_size", 13)
		header_hbox.add_child(town_lbl)

		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(spacer)

		var tag_lbl := Label.new()
		tag_lbl.text = "[ %s ]" % rumor["tag"]
		tag_lbl.add_theme_color_override("font_color", Color(0.85, 0.5, 0.3))
		tag_lbl.add_theme_font_size_override("font_size", 12)
		header_hbox.add_child(tag_lbl)

		var text_lbl := Label.new()
		text_lbl.text = rumor["rumor"]
		text_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.58))
		text_lbl.add_theme_font_size_override("font_size", 12)
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(text_lbl)

# --- Helper logic ---
func _auto_expand_first() -> void:
	var candidates: Array = _masters.town_candidates.get(town_name, [])
	if not candidates.is_empty():
		_expanded_candidate_id = candidates[0].id
	else:
		_expanded_candidate_id = ""

func _clear_container(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func _get_archetype_name(full_name: String) -> String:
	var lower_name = full_name.to_lower()
	if "apprentice" in lower_name:
		return "Apprentice Master"
	elif "runner" in lower_name:
		return "Swift Runner"
	elif "hauler" in lower_name:
		return "Reliable Hauler"
	elif "veteran" in lower_name:
		return "Veteran Master"
	return "Caravan Master"

func _get_focus_stat(candidate: CaravanMaster) -> String:
	var speed_val := candidate.speed
	var cap_val := candidate.get_capacity()
	var bargain_val := candidate.bargaining
	var courage_val := candidate.courage
	
	var max_val = max(max(speed_val, cap_val / 10), max(bargain_val, courage_val))
	if max_val == speed_val:
		return "Speed"
	elif max_val == cap_val / 10:
		return "Capacity"
	elif max_val == bargain_val:
		return "Bargain"
	else:
		return "Safety"

func _get_archetype_flavor(full_name: String) -> String:
	var lower_name = full_name.to_lower()
	if "apprentice" in lower_name:
		return "An eager apprentice looking to learn the ropes of long-distance trading."
	elif "runner" in lower_name:
		return "Fast and light, built to outrun danger and deliver goods quickly."
	elif "hauler" in lower_name:
		return "A strong transport specialist capable of carrying massive loads of cargo."
	elif "veteran" in lower_name:
		return "An experienced trade commander with balanced skills in all aspects of caravan management."
	return "A reliable caravan master looking for a contract."

func _get_archetype_traits(full_name: String) -> Array[String]:
	var lower_name = full_name.to_lower()
	if "apprentice" in lower_name:
		return ["Eager", "Cheap Upkeep", "Learner"]
	elif "runner" in lower_name:
		return ["Swift", "Fragile", "Alert"]
	elif "hauler" in lower_name:
		return ["Steady", "Heavy Cargo", "Low Risk"]
	elif "veteran" in lower_name:
		return ["Experienced", "Bargainer", "Guarded"]
	return ["Reliable", "Determined"]
