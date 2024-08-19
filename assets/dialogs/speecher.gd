extends Node
class_name Speecher
@export var author: StringName
@export var audioPlayer: Node

signal finished

func _ready() -> void:
	var s = self
	if s is AudioStreamPlayer || s is AudioStreamPlayer3D:
		audioPlayer = s
	if !audioPlayer:
		var c := find_children("*", "AudioStreamPlayer")
		if c.size():
			audioPlayer = c[0]
	if !audioPlayer:
		var c := find_children("*", "AudioStreamPlayer3D")
		if c.size():
			audioPlayer = c[0]
	assert(audioPlayer, "AudioStreamPlayer should be setted or be a child of this node")
	DialogsSystem.register(self)
	audioPlayer.bus = "Speech"

func speech(line: SpeechLine):
	audioPlayer.stream = line.sound
	audioPlayer.play()
	audioPlayer.finished.connect(func(): finished.emit(), Object.ConnectFlags.CONNECT_ONE_SHOT)
	await audioPlayer.finished
