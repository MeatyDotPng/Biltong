extends CharacterBody2D

@export var speed = 75
@export var last_input_y = 0
@export var throw_force = 400

@onready var player_body = $PlayerBody
@onready var animation_player = $AnimationPlayer
@onready var item_holder_one = $ItemHolderOne
@onready var item_holder_two = $ItemHolderTwo
@onready var interaction_area = $InteractionArea
@onready var throw_direction_arrow = $ThrowDirectionArrow
@onready var animation_tree : AnimationTree = $AnimationTree

var held_item: BaseThrowable = null

var is_dragging = false
var drag_start_pos = Vector2()
var max_drag_distance = 300.0
var direction : Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true

func _physics_process(_delta):
	direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized()
	update_animation_parameters()

	velocity = speed * direction
	move_and_slide()

	if held_item:
		held_item.global_position = item_holder_one.global_position

func _input(event):
	# Handle item pickup
	if event.is_action_pressed("pickup") and held_item == null:
		pick_up_closest_item()
	
	# Handle drag start
	if held_item and event is InputEventMouseButton:
		if event.pressed:
			# Start drag from the player's current global position
			drag_start_pos = global_position
			is_dragging = true
			throw_direction_arrow.visible = true
			throw_direction_arrow.global_position = global_position
		else:
			# End drag on mouse release if dragging was in progress
			if is_dragging:
				end_drag_and_throw(event)

	# Update visual feedback for dragging
	if event is InputEventMouseMotion and is_dragging and held_item:
		update_drag_visual(event.position)

func end_drag_and_throw(event):
	# End the dragging process and handle the throw
	is_dragging = false
	throw_direction_arrow.visible = false  # Ensure arrow is hidden when drag ends
	calculate_and_throw(get_global_mouse_position())

# Hide arrow if mouse button is released outside of normal event flow
func _unhandled_input(event):
	# Hide arrow if mouse button is released outside of normal event flow
	if event is InputEventMouseButton and not event.pressed and is_dragging:
		end_drag_and_throw(event)

func pick_up_closest_item():
	var items = interaction_area.get_overlapping_areas()
	for item in items:
		if item is BaseThrowable and !item.is_held:
			held_item = item
			item.position = Vector2()
			item.is_held = true
			item.z_index = 1
			break

func throw_item(direction_throw, force):
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 0.2
	timer.timeout.connect(_timer_Timeout)
	timer.start()
	
	if held_item:
		held_item.throw(direction_throw, force)

func _timer_Timeout():
		held_item = null

func calculate_and_throw(mouse_global_pos):
	# drag_start_pos is now player's position
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

func update_animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	
	if held_item:
		if Input.is_action_just_released("throw_left"):
			animation_tree["parameters/conditions/throw_left"] = true
		else:
			animation_tree["parameters/conditions/throw_left"] = false
	
		if Input.is_action_just_released("throw_right"):
			animation_tree["parameters/conditions/throw_right"] = true
		else:
			animation_tree["parameters/conditions/throw_right"] = false
	
	# To hold the correct direction
	if direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Left_Arm_Throw/blend_position"] = direction
		animation_tree["parameters/Right_Arm_Throw/blend_position"] = direction
