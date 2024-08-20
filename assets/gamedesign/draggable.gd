extends Area3D
class_name Draggable

@export var shape: CollisionShape3D
@export var trigger: TriggerItem

signal taken()

func _ready() -> void:
	if !shape:
		shape = find_children("*", "CollisionShape3D")[0]

func drag():
	taken.emit()
	shape.disabled = true

func drop():
	shape.disabled = false
