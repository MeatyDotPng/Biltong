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

func _physics_process(delta):
	direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized()
	update_animation_parameters()

	velocity = speed * direction
	move_and_slide()

	if held_item:
		held_item.global_position = item_holder_one.global_position

func _input(event):
	# Pick up item if close enough and pickup action is triggered
	if event.is_action_pressed("pickup") and held_item == null:
		pick_up_closest_item()
	if held_item != null:
		if event is InputEventMouseButton:
			if event.pressed:
				 # Start drag from the player's current global position
				drag_start_pos = global_position
				is_dragging = true
				
				throw_direction_arrow.visible = true
				 # Position the arrow at the player's position
				throw_direction_arrow.global_position = global_position
			else:
				# End drag and calculate throw
				if is_dragging:
					is_dragging = false
					throw_direction_arrow.visible = false
					 # Use global mouse position to calculate
					calculate_and_throw(get_global_mouse_position())

	if event is InputEventMouseMotion and is_dragging and held_item != null:
		update_drag_visual(event.position)

func pick_up_closest_item():
	var items = interaction_area.get_overlapping_areas()
	for item in items:
		if item is BaseThrowable and !item.is_held:
			held_item = item
			item.position = Vector2()
			item.is_held = true
			break

func throw_item(direction, force):
	if held_item:
		held_item.global_position = item_holder_one.global_position
		held_item.throw(direction, force)
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
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		
	if(Input.is_action_just_released("throw_left")):
		animation_tree["parameters/conditions/throw_left"] = true
	else:
		animation_tree["parameters/conditions/throw_left"] = false
	
	if(Input.is_action_just_released("throw_right")):
		animation_tree["parameters/conditions/throw_right"] = true
	else:
		animation_tree["parameters/conditions/throw_right"] = false
	
	if(direction != Vector2.ZERO):
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Left_Arm_Throw/blend_position"] = direction
		animation_tree["parameters/Right_Arm_Throw/blend_position"] = direction
