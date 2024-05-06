extends CharacterBody2D

@export var speed = 75
@export var gravity = 30
@export var last_input_y = 0
@export var throw_force = 400

@onready var player_body = $PlayerBody
@onready var animation_player = $AnimationPlayer
@onready var item_holder_one = $ItemHolderOne
@onready var item_holder_two = $ItemHolderTwo
@onready var interaction_area = $InteractionArea
@onready var throw_direction_arrow = $ThrowDirectionArrow

var held_item: BaseThrowable = null

var is_dragging = false
var drag_start_pos = Vector2()
var max_drag_distance = 300.0

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")

	handle_input_vector(input_vector)

	self.velocity = speed * input_vector.normalized()
	self.move_and_slide()
	
	if held_item:
		held_item.global_position = item_holder_one.global_position

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
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and held_item != null:
		if event.pressed:
			# Start drag
			drag_start_pos = global_position
			is_dragging = true
			
			throw_direction_arrow.visible = true
			throw_direction_arrow.global_position = global_position
		else:
			# End drag and calculate throw
			if is_dragging:
				is_dragging = false
				throw_direction_arrow.visible = false
				calculate_and_throw(get_global_mouse_position())
				
	if event is InputEventMouseMotion and is_dragging and held_item != null:
		update_drag_visual(event.position)

func pick_up_closest_item():
	var items = interaction_area.get_overlapping_areas()
	for item in items:
		if item is BaseThrowable and !item.is_held:
			held_item = item
			item.position = Vector2()
			item_holder_one.add_child(item)
			item.is_held = true
			break

func throw_item(direction, force):
	if held_item:
		animation_player.play("front_throw_left")  # Ensure you have this animation or adjust accordingly
		await get_tree().create_timer(2.0)  # Wait for half a second; adjust based on animation length
		# Assuming the animation is around 0.5 seconds long
		item_holder_one.remove_child(held_item)
		held_item.global_position = item_holder_one.global_position
		held_item.throw(direction, force)
		held_item = null

func calculate_and_throw(mouse_global_pos):
	var drag_vector = mouse_global_pos - drag_start_pos
	var drag_length = drag_vector.length()
	
	if drag_length > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance
		drag_length = max_drag_distance
	
	var throw_strength = map(drag_length, 0, max_drag_distance, 0, throw_force)
	throw_item(drag_vector.normalized(), throw_strength)

func update_drag_visual(current_pos):
	var drag_vector = current_pos - drag_start_pos
	var drag_length = drag_vector.length()
	if drag_length > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance
	
	# Update arrow rotation to point in the direction of the drag
	throw_direction_arrow.rotation = drag_vector.angle()

func map(value, from_min, from_max, to_min, to_max):
	return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min

func _on_animation_player_animation_finished(anim_name):
	print("Animation finished: ", anim_name)
	if anim_name == "front_throw_left" and held_item:
		print("Throwing item.")
		item_holder_one.remove_child(held_item)
		held_item.global_position = item_holder_one.global_position
		var mouse_position = get_global_mouse_position()
		var throw_direction = (mouse_position - global_position).normalized()
		held_item.throw(throw_direction, held_item.throw_force)
		held_item = null

