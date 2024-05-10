extends BaseThrowable

@onready var mushroom = $Mushroom

var death = false

func _ready():
	mushroom.visible = false
	connect("stopped_moving", Callable(self, "_on_stopped_moving"))

func _on_area_entered(area):
	mushroom.visible = true
	mushroom.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)

func _on_stopped_moving():
	# Play death animation if conditions are met
	if was_thrown:
		# play death sound and animation
		mushroom.play("death")
		death = true

func _on_mushroom_animation_finished():
	if death:
		queue_free()

