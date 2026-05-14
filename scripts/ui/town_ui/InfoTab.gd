extends TownTab

func build() -> void:
	# Clean up previous dynamic children (like event card)
	for child in panel.get_children():
		if child != panel.get_node("InfoLabel"):
			child.queue_free()

	# --- Aktif olay kartı ---
	if _events != null and _events.has_event(town_name):
		var event: Dictionary = _events.get_event(town_name)
		var event_color: Color = event.get("color", Color.WHITE)
		var days_left: int = int(event.get("ends_day", 0)) - int(_economy.current_day)

		var event_card = Label.new()
		event_card.text = "[%s] %s\n%s\nEnds in %d day(s)." % [
			str(event.get("name", "")),
			str(event.get("icon", "")),
			str(event.get("description", "")),
			max(days_left, 0),
		]
		event_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		event_card.add_theme_color_override("font_color", event_color)
		event_card.add_theme_font_size_override("font_size", 15)
		panel.add_child(event_card)
		panel.move_child(event_card, 0)

	# --- Mevcut info ---
	var town = _economy.get_town(town_name)
	var faction_name = town.get("faction", "")
	var faction_data = _faction.get_faction_data(faction_name)
	var rep = _player.get_faction_rep(faction_name)
	var tax = _faction.get_tax_rate(faction_name)

	var lbl = panel.get_node("InfoLabel")
	lbl.text = """Town: %s
Faction: %s
Population: %d

%s

Your reputation: %s (%.0f)
Travel tax rate: %.0f%%

Produces: %s
Consumes: %s

Last production report:
%s""" % [
		town_name,
		faction_name,
		town.get("population", 0),
		faction_data.get("description", ""),
		_faction.get_relation_description(rep), rep,
		tax * 100.0,
		", ".join(town.get("production_plan", {}).keys()),
		", ".join(town.get("consumption_rules", {}).keys()),
		ui._format_town_report(_economy.get_town_report(town_name)),
	]
