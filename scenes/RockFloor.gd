extends BaseThrowable

@onready var rock = $Rock

var death = false

func _ready():
	rock.visible = false
	connect("stopped_moving", Callable(self, "_on_stopped_moving"))

func _on_area_entered(area):
	rock.visible = true
	rock.z_index = -1
	
	if area.has_method("apply_effect"):
		area.apply_effect(self)

func _on_stopped_moving():
	# Play death animation if conditions are met
	if was_thrown:
		# play death sound and animation
		rock.play("death")
		death = true

func _on_rock_animation_finished():
	if death:
		queue_free()
