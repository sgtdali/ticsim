extends Control

signal closed

func _ready() -> void:
	$Panel/VBox/ContinueBtn.pressed.connect(_on_continue)

func show_attack(lost_items: Dictionary) -> void:
	var lines: Array[String] = []
	for item in lost_items:
		lines.append("- %s: %d" % [str(item).capitalize(), int(lost_items[item])])
	if lines.is_empty():
		$Panel/VBox/LossList.text = "(No cargo to lose)"
	else:
		$Panel/VBox/LossList.text = "\n".join(lines)

func _on_continue() -> void:
	emit_signal("closed")
	queue_free()
