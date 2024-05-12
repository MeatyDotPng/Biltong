extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

var burnt = false

func _ready():
	animated_sprite_2d.play("idle")
	
	if burnt:
		animated_sprite_2d.play("burnt")

func _on_burn_area_area_entered(area):
	if area.name == "FireMango":
		animated_sprite_2d.play("burning")
		burnt = true
	elif burnt:
		animated_sprite_2d.play("burnt")

func _on_animated_sprite_2d_animation_finished():
	if burnt:
		animated_sprite_2d.play("burnt")
		collision_shape_2d.disabled = true
