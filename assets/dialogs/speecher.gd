extends Node
class_name Speecher
@export var author: StringName
@export var audioPlayer: Node

var dying := false

signal finished
signal started

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
	tree_exiting.connect(func():
		dying = true
		if audioPlayer.playing:
			finished.emit()
	)

func speech(line: SpeechLine):
	started.emit()
	audioPlayer.stream = line.sound
	audioPlayer.play()
	audioPlayer.finished.connect(func(): finished.emit(), Object.ConnectFlags.CONNECT_ONE_SHOT)
	await audioPlayer.finished
