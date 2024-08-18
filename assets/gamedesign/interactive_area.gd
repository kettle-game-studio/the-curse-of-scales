extends Area3D

class_name InteractiveArea

func _init() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)
	
func _on_body_entered(body: Node3D):
	if body is Player:
		body.on_enter_interactive_area(self)

func _on_body_exit(body: Node3D):
	if body is Player:
		body.on_exit_interactive_area(self)
