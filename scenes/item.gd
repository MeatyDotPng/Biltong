extends BaseThrowable

func _ready():
	throw_force = 130

func _on_area_entered(area):
	print(area, " IS IN MY AREA")
	handle_interaction(area)

func handle_interaction(area):
	if area.has_method("apply_effect"):
		area.apply_effect(self)