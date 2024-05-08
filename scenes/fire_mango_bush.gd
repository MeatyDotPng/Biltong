extends StaticBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var in_pickup_area = $InPickupArea

var can_pick_up = false
var is_picked = false

# after is picked you can start a timer and a new mango can grow back over time

func _on_in_pickup_area_area_entered(area):
	if area.name == "InteractionArea":
		if not is_picked:
			can_pick_up = true
			animated_sprite_2d.play("pickup")
		else:
			animated_sprite_2d.play("picked")

func _on_in_pickup_area_area_exited(area):
	if area.name == "InteractionArea":
		if not is_picked:
			can_pick_up = false  
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("picked")

func _input(event):
	# Check if the 'pickup' action was pressed and if the player can currently pick up an item.
	if event.is_action_pressed("pickup") and can_pick_up and not is_picked:
		animated_sprite_2d.play("picked")
		perform_pickup()

func perform_pickup():
	# set bools accordingly
	can_pick_up = false
	is_picked = true
