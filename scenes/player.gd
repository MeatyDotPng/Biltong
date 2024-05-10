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

var held_item_one: BaseThrowable = null
var held_item_two: BaseThrowable = null

var is_dragging = false
var drag_start_pos = Vector2()
var max_drag_distance = 300.0
var direction : Vector2 = Vector2.ZERO
var drag_with_left = false
var drag_with_right = false

func _ready():
	animation_tree.active = true

func _physics_process(_delta):
	direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized()
	update_animation_parameters()

	velocity = speed * direction
	move_and_slide()

	if held_item_one:
		held_item_one.global_position = item_holder_one.global_position
	
	if held_item_two:
		held_item_two.global_position = item_holder_two.global_position

func _input(event):
	# Handle item pickup
	if event.is_action_pressed("pickup"):
		pick_up_closest_item()

	# Handle drop
	if event.is_action_pressed("drop"):
		drop_item()

	# Start dragging and show direction arrow based on which item and button are pressed
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and held_item_one:
			drag_with_left = true
			start_dragging(event.global_position, item_holder_one)
		elif event.button_index == MOUSE_BUTTON_RIGHT and held_item_two:
			drag_with_right = true
			start_dragging(event.global_position, item_holder_two)
	
	# End dragging and initiate throw when mouse button is released
	if event is InputEventMouseButton and not event.pressed:
		if (event.button_index == MOUSE_BUTTON_LEFT and held_item_one) or (event.button_index == MOUSE_BUTTON_RIGHT and held_item_two):
			end_drag_and_throw(held_item_one if event.button_index == MOUSE_BUTTON_LEFT else held_item_two, item_holder_one if event.button_index == MOUSE_BUTTON_LEFT else item_holder_two, event.global_position)

	# Update visual feedback for dragging
	if event is InputEventMouseMotion and is_dragging:
		update_drag_visual(event.position)

func start_dragging(event_global_position, item_holder):
	drag_start_pos = event_global_position
	is_dragging = true
	throw_direction_arrow.visible = true
	throw_direction_arrow.global_position = item_holder.global_position

func end_drag_and_throw(held_item, item_holder, mouse_global_pos):
	is_dragging = false
	throw_direction_arrow.visible = false
	calculate_and_throw(held_item, item_holder, mouse_global_pos)

	# Reset the drag flags
	if held_item == held_item_one:
		drag_with_left = false
	elif held_item == held_item_two:
		drag_with_right = false

func drop_item():
	if held_item_one:
		held_item_one.is_held = false  # Mark the item as not held
		held_item_one.global_position = position  # Drop at the player's position
		held_item_one = null  # Clear the held item
	elif held_item_two:
		held_item_two.is_held = false  # Mark the item as not held
		held_item_two.global_position = position  # Drop at the player's position
		held_item_two = null  # Clear the held item

func pick_up_closest_item():
	var items = interaction_area.get_overlapping_areas()
	for item in items:
		if item is BaseThrowable and !item.is_held:
			if not held_item_one:
				held_item_one = item
				item.global_position = item_holder_one.global_position
				item.is_held = true
				break
			elif not held_item_two:
				held_item_two = item
				item.global_position = item_holder_two.global_position
				item.is_held = true
				break

func throw_item(held_item, direction_throw, force):
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.3

	# Create a Callable object that includes the method and the extra parameter
	var callable = Callable(self, "_timer_Timeout")
	callable = callable.bind(held_item)  # Binding the held_item to the callable

	# Connect the timeout signal to the callable
	timer.connect("timeout", callable)
	timer.start()

	# Proceed to throw the item
	held_item.throw(direction_throw, force)

func _timer_Timeout(held_item):
	# Correctly handle the freeing or nullifying of the thrown item
	if held_item == held_item_one:
		held_item_one = null
	elif held_item == held_item_two:
		held_item_two = null

func calculate_and_throw(held_item, item_holder, mouse_global_pos):
	var drag_vector = mouse_global_pos - drag_start_pos
	var drag_length = drag_vector.length()
	if drag_length > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance

	var throw_strength = map(drag_length, 0, max_drag_distance, 0, throw_force)
	throw_item(held_item, drag_vector.normalized(), throw_strength)

func update_drag_visual(current_pos):
	var drag_vector = current_pos - drag_start_pos
	var drag_length = drag_vector.length()

	# Clamp the drag vector to the maximum distance
	if drag_length > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance
		drag_length = max_drag_distance

func map(value, from_min, from_max, to_min, to_max):
	return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min

func update_animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		
		if Input.is_action_just_pressed("climb"):
			animation_tree["parameters/conditions/is_climbing"] = true
		else:
			animation_tree["parameters/conditions/is_climbing"] = false
		
		if held_item_one:
			if Input.is_action_just_released("throw_left"):
				animation_tree["parameters/conditions/idle_throw_l"] = true
			else:
				animation_tree["parameters/conditions/idle_throw_l"] = false
		elif held_item_two:
			if Input.is_action_just_released("throw_right"):
				animation_tree["parameters/conditions/idle_throw_r"] = true
			else:
				animation_tree["parameters/conditions/idle_throw_r"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		
		if Input.is_action_just_pressed("climb"):
			animation_tree["parameters/conditions/is_climbing"] = true
		else:
			animation_tree["parameters/conditions/is_climbing"] = false
		
		if held_item_one:
			if Input.is_action_just_released("throw_left"):
				animation_tree["parameters/conditions/is_moving_throw_l"] = true
			else:
				animation_tree["parameters/conditions/is_moving_throw_l"] = false
		elif held_item_two:
			if Input.is_action_just_released("throw_right"):
				animation_tree["parameters/conditions/is_moving_throw_r"] = true
			else:
				animation_tree["parameters/conditions/is_moving_throw_r"] = false
	
	# To hold the correct direction
	if direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Climb/blend_position"] = direction
		animation_tree["parameters/Idle_Throw_Left/blend_position"] = direction
		animation_tree["parameters/Idle_Throw_Right/blend_position"] = direction
		animation_tree["parameters/Run_Throw_Left/blend_position"] = direction
		animation_tree["parameters/Run_Throw_Right/blend_position"] = direction
