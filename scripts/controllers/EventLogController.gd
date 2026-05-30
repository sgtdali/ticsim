extends RefCounted
class_name EventLogController

const MAX_MESSAGES := 3

var _wm: Node
var _messages: Array[Dictionary] = []

func _init(world_map: Node) -> void:
	_wm = world_map

func add_message(message: String, color: Color) -> void:
	_messages.push_front({"message": message, "color": color})
	if _messages.size() > MAX_MESSAGES:
		_messages.resize(MAX_MESSAGES)
	update_panel()

func update_panel() -> void:
	var list := _wm.get_node_or_null("UI/EventPanel/EventMargin/EventVBox/EventList") as VBoxContainer
	if list == null:
		return
	MapUtils.clear_container(list)
	if _messages.is_empty():
		MapUtils.add_muted_label(list, "No active event alerts.")
		return
	for entry in _messages:
		var label := Label.new()
		label.text = str(entry.get("message", ""))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", entry.get("color", Color.WHITE))
		label.add_theme_font_size_override("font_size", 12)
		list.add_child(label)

func on_event_started(town_name: String, event: Dictionary) -> void:
	_wm._refresh_buttons()
	if event.is_empty():
		return
	add_message(
		"%s: %s begins!" % [town_name, str(event.get("name", ""))],
		event.get("color", Color.WHITE)
	)

func on_event_ended(town_name: String, event: Dictionary) -> void:
	_wm._refresh_buttons()
	if event.is_empty():
		return
	add_message(
		"%s: %s ended." % [town_name, str(event.get("name", ""))],
		event.get("color", Color.WHITE)
	)
