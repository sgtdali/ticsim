extends TownTab

func build() -> void:
	var container = panel.get_node("NPCList")
	for child in container.get_children():
		child.queue_free()

	var npcs = _faction.get_npcs_in_town(town_name)
	if npcs.is_empty():
		var lbl = Label.new()
		lbl.text = "No notable persons here."
		container.add_child(lbl)
		return

	for entry in npcs:
		var data = entry["data"]
		var npc_id = entry["id"]
		var relation = _player.get_npc_relation(npc_id)
		var rel_desc = _faction.get_relation_description(relation)

		var card = VBoxContainer.new()
		card.add_theme_constant_override("separation", 2)

		var name_lbl = Label.new()
		name_lbl.text = "%s — %s" % [data["name"], data["role"]]
		card.add_child(name_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = data["description"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(desc_lbl)

		var rel_lbl = Label.new()
		rel_lbl.text = "Relation: %s (%.0f)" % [rel_desc, relation]
		card.add_child(rel_lbl)

		var sep = HSeparator.new()
		container.add_child(card)
		container.add_child(sep)
