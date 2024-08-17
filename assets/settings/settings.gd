extends Resource
class_name Settings

@export var mouse_sensitivity: float
@export var joystick_sensitivity: float
@export var sounds_volume: float:
	get:
		return db_to_linear(AudioServer.get_bus_volume_db(_sounds_bus_index))
	set(value):
		AudioServer.set_bus_volume_db(_sounds_bus_index, linear_to_db(value))
@export var music_volume: float:
	get:
		return db_to_linear(AudioServer.get_bus_volume_db(_music_bus_index))
	set(value):
		AudioServer.set_bus_volume_db(_music_bus_index, linear_to_db(value))


var _sounds_bus_index: int
var _music_bus_index: int
func _init():
	_sounds_bus_index = AudioServer.get_bus_index("Sounds")
	_music_bus_index = AudioServer.get_bus_index("Music")
