extends BaseThrowable

@onready var mango = $Mango

var death = false

func _ready():
	mango.visible = false
	connect("stopped_moving", Callable(self, "_on_stopped_moving"))

func _on_area_entered(area):
	mango.visible = true
	mango.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)

func _on_stopped_moving():
	# Play death animation if conditions are met
	if was_thrown:
		# play death sound and animation
		mango.play("death")
		death = true

func _on_mango_animation_finished():
	if death:
		queue_free()
