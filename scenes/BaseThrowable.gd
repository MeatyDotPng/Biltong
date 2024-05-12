extends Area2D

class_name BaseThrowable

var initial_velocity = Vector2()
var high_deceleration = 0.01
var low_deceleration = 0.05
var throw_sound = "res://assets/audio/sounds/throw.mp3"
var hit_ground = "res://assets/audio/sounds/Throwable-Collision.mp3"
var is_held = false
var is_rolling = false
var has_hit_ground = false
var already_playing = false
var was_thrown = false
var playing_death_now = false

signal picked_up
signal dropped
signal thrown
signal stopped_moving

func _ready():
	connect("picked_up", Callable(self, "_on_picked_up"))
	connect("dropped", Callable(self, "_on_dropped"))
	connect("playing_death", Callable(self, "_on_playing_death"))

func _physics_process(delta):
	if not is_held and was_thrown:
		if not is_rolling:
			# Apply high deceleration initially
			initial_velocity *= high_deceleration ** delta
			position += initial_velocity * delta
			# Check if velocity is low enough to start rolling
			if initial_velocity.length() < 25 and not is_rolling:
				is_rolling = true
				has_hit_ground = false  # Reset ground hit sound trigger
		else:
			# Apply lower deceleration for rolling
			initial_velocity *= low_deceleration ** delta
			position += initial_velocity * delta
			# Play ground hit sound once when starting to roll
			if not has_hit_ground:
				play_sound(hit_ground)
				has_hit_ground = true
		# Stop completely if velocity is very low
		if initial_velocity.length() < 20:
			initial_velocity = Vector2.ZERO
			is_rolling = false
			emit_signal("stopped_moving")

func _on_playing_death():
	playing_death_now = true
	is_held = false

func _on_picked_up():
	if not playing_death_now:
		is_held = true
		was_thrown = false
		initial_velocity = Vector2()
		is_rolling = false
		has_hit_ground = false

func _on_dropped():
	is_held = false
	is_rolling = false
	has_hit_ground = false
	was_thrown = false

func throw(direction, force):
	if is_held and not already_playing:
		var timer : Timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.autostart = false
		timer.wait_time = 0.2
		timer.timeout.connect(_timer_Timeout)
		timer.start()
		already_playing = true
		was_thrown = true
		emit_signal("thrown")
		
		initial_velocity = direction * force

func _timer_Timeout():
	is_held = false
	is_rolling = false
	has_hit_ground = false
	play_sound(throw_sound)
	emit_signal("dropped")

func play_sound(sound_path):
	var sound = AudioStreamPlayer.new()
	sound.stream = load(sound_path)
	add_child(sound)
	sound.play()
	already_playing = false
