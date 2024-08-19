extends Area3D

class_name Triggable

@export var action_name: StringName
@export var trigger: TriggerItem
@export var one_shot := true
@export var triggerable_when_small := false

signal triggered(item: TriggerItem)

var activated := false

func activable(item: TriggerItem) -> bool:
	return !(one_shot && activated) && (!trigger || item == trigger)

func activate(item: TriggerItem) -> bool:
	if activable(item):
		monitorable = false
		activated = true
		triggered.emit(item)
		return true
	return false
