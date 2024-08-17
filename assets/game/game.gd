extends Node

@onready var main_menu: PanelContainer = $MainMenu

func _ready() -> void:
	main_menu.open()
