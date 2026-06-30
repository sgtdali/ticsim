extends Control

func _ready() -> void:
	get_node("VBox/StartBtn").pressed.connect(_on_start)
	get_node("VBox/QuitBtn").pressed.connect(_on_quit)

	var continue_btn := get_node("VBox/ContinueBtn") as BaseButton
	var has_save: bool = get_node("/root/SaveManager").has_save()
	continue_btn.visible = has_save
	get_node("VBox/SpacerContinue").visible = has_save
	if has_save:
		continue_btn.pressed.connect(_on_continue)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_continue() -> void:
	get_node("/root/SaveManager").pending_load = true
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_quit() -> void:
	get_tree().quit()
