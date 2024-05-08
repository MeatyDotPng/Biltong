extends BaseThrowable

@onready var mango = $Mango

func _ready():
	mango.visible = false

func _on_area_entered(area):
	mango.visible = true
	mango.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)
