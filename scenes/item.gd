extends BaseThrowable

func _ready():
	pass

func _on_area_entered(area):
	handle_interaction(area)

func handle_interaction(area):
	if area.has_method("apply_effect"):
		area.apply_effect(self)
