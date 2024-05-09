extends BaseThrowable

@onready var mushroom = $Mushroom

func _ready():
	mushroom.visible = false

func _on_area_entered(area):
	mushroom.visible = true
	mushroom.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)
