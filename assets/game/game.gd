extends Node

@onready var main_menu: PanelContainer = $MainMenu

func _ready() -> void:
	main_menu.open()

@export var intro_speech: SpeechLine

func intro():
	DialogsSystem.play(intro_speech)
