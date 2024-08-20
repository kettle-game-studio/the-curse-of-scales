extends Node

@onready var main_menu: PanelContainer = $MainMenu
@export var titles: PackedScene
func _ready() -> void:
	main_menu.open()

@export var intro_speech: SpeechLine

func intro():
	DialogsSystem.play(intro_speech)


func _on_final_dialog_finished() -> void:
	get_tree().paused = true
	add_child(titles.instantiate())
