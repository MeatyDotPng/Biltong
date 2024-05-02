extends Area2D

class_name BaseThrowable

var initial_velocity = Vector2()
var deceleration = 50
var throw_force = 200
var throw_sound = "res://assets/audio/sounds/throw.mp3"
var is_held = false

signal picked_up
signal dropped

func _ready():
	connect("picked_up", Callable(self, "_on_picked_up"))
	connect("dropped", Callable(self, "_on_dropped"))

func _physics_process(delta):
	if not is_held:
		# Apply deceleration to slow down the item over time
		initial_velocity = initial_velocity.move_toward(Vector2.ZERO, deceleration * delta)
		position += initial_velocity * delta
		if initial_velocity.length() < 1:
			initial_velocity = Vector2.ZERO  # Stop completely if velocity is very low

func _on_picked_up():
	is_held = true
	initial_velocity = Vector2()  # Reset velocity when picked up

func _on_dropped():
	is_held = false

func throw(direction):
	if is_held:
		is_held = false
		initial_velocity = direction.normalized() * throw_force
		play_sound(throw_sound)
		emit_signal("dropped")

func play_sound(sound_path):
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_path)
	add_child(sound)
	sound.play()
