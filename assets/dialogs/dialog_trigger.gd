extends Node

@export var dialog: Dialog

signal finished

func play():
	await DialogsSystem.play_dialog(dialog)
	finished.emit()
