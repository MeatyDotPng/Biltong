extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var larger_detection_area = $LargerDetectionArea

var speed = 75
var target_position: Vector2 = Vector2()
var can_move = false

func _physics_process(delta):
	if can_move and position.distance_to(target_position) > 10:
		var move_direction = (target_position - position).normalized()
		velocity = move_direction * speed
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		can_move = false  # Stop moving once the target is reached

func _on_enemies_interaction_area_area_entered(area):
	if area.name == "PoisonMushroom":
		sprite_2d.flip_v = true

func _on_larger_detection_area_area_entered(area):
	connect("thrown", Callable(self, "_on_thrown"))
	
	if area.name == "Rock":
		target_position = area.global_position
		can_move = true
		print("Moving towards rock at: ", target_position)

func _on_thrown():
	can_move = true
