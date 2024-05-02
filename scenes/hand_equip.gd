extends BaseThrowable

func _init():
	throw_force = 50 # Rocks can be thrown with medium force

func _on_area_2d_area_entered(area):
	print(area, " IS IN MY AREA")
