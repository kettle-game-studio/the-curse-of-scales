extends Triggable

class_name Mars

func activable(item: TriggerItem) -> bool:
	return item is Bottle

func activate(item: TriggerItem) -> bool:
	if item is Bottle:
		triggered.emit(item)
		return true
	return false
