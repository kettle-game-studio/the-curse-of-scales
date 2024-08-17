extends HSlider

@export var field_name: StringName
@export var settings: Settings = load("res://assets/settings/settings.tres")

func _ready():
	value = settings[field_name]
	value_changed.connect(_on_value_changed)

func _on_value_changed(value: float):
	settings[field_name] = value
