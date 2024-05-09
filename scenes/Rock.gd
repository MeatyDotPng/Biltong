extends BaseThrowable

@onready var rock = $Rock

func _on_area_entered(area):
	rock.visible = true
	rock.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)
