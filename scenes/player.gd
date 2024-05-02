extends CharacterBody2D

@export var speed = 75
@export var gravity = 30
@export var last_input_y = 0

@onready var player_body = $PlayerBody
@onready var animation_player = $AnimationPlayer
@onready var item_holder_one = $ItemHolderOne
@onready var item_holder_two = $ItemHolderTwo
@onready var interaction_area = $InteractionArea

var held_item: BaseThrowable = null

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")

	handle_input_vector(input_vector)

	self.velocity = speed * input_vector.normalized()
	self.move_and_slide()
	
	if held_item:
		held_item.global_position = item_holder_one.global_position

	# Handle throwing logic if an item is held and throw button is pressed
	if Input.is_action_just_pressed("throw") and held_item:
		throw_item()

func handle_input_vector(input_vector):
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		player_body.flip_h = input_vector.x < 0
		
		if abs(input_vector.x) > 0:
			animation_player.play("run_side")
		elif input_vector.y > 0:
			animation_player.play("run_front")
		elif input_vector.y < 0:
			animation_player.play("run_back")
			
		last_input_y = input_vector.y
	else:
		if last_input_y > 0:
			animation_player.play("idle_front")
		elif last_input_y < 0:
			animation_player.play("idle_back")
		else:
			animation_player.play("idle_side")

func _input(event):
	# Pick up item if close enough and pickup action is triggered
	if event.is_action_pressed("pickup") and held_item == null:
		pick_up_closest_item()

func pick_up_closest_item():
	var items = interaction_area.get_overlapping_areas()
	for item in items:
		if item is BaseThrowable and !item.is_held:
			held_item = item
			item.position = Vector2()
			item_holder_one.add_child(item)
			item.is_held = true
			break

func throw_item():
	animation_player.play("front_throw_left")
	# Delayed manual call for testing
	await get_tree().create_timer(2.0)
	_on_animation_player_animation_finished("front_throw_left")

func _on_animation_player_animation_finished(anim_name):
	print("Animation finished: ", anim_name)
	if anim_name == "front_throw_left" and held_item:
		print("Throwing item.")
		item_holder_one.remove_child(held_item)
		held_item.global_position = item_holder_one.global_position
		var mouse_position = get_global_mouse_position()
		var throw_direction = (mouse_position - global_position).normalized()
		held_item.throw(throw_direction * held_item.throw_force)
		held_item = null
