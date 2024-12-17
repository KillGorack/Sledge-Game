extends OmniLight3D

var pulse_duration: float = 0.2
var pause_duration: float = 1
var max_intensity: float = 4.0
var time_passed: float = 0.0
var is_pulsing: bool = true

func _process(delta: float):
	time_passed += delta
	
	if is_pulsing:
		light_energy = max_intensity
		if time_passed >= pulse_duration:
			time_passed = 0.0
			is_pulsing = false
	else:
		light_energy = 0
		if time_passed >= pause_duration:
			time_passed = 0.0
			is_pulsing = true
