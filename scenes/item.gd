extends BaseThrowable

func _on_area_entered(area):
	if area.has_method("apply_effect"):
		area.apply_effect(self)
