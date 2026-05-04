extends Control

func _ready() -> void:
	get_node("VBox/StartBtn").pressed.connect(_on_start)
	get_node("VBox/QuitBtn").pressed.connect(_on_quit)

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_quit() -> void:
	get_tree().quit()
