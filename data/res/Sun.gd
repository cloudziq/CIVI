extends DirectionalLight

# Parametry cyklu dnia
var day_length :=  20.0  # Czas całego dnia w sekundach
var sun_angle  :=  22.0  # Startowy kąt słońca (tuż przed wschodem)
var moon_angle := -60.0  # Startowy kąt księżyca

# Światła i kolory
var morning_intensity := 0.8
var afternoon_intensity := 1.0
var sunset_intensity := 0.6
var night_intensity := 0.02

var morning_light_color := Color(1.0, 0.7, 0.5)
var afternoon_light_color := Color(1.0, 1.0, 1.0)
var sunset_light_color := Color(1.0, 0.4, 0.3)
var night_light_color := Color(0.1, 0.1, 0.4)

# Wartości dla background_energy
var morning_energy := 0.6
var afternoon_energy := 1.0
var sunset_energy := 0.6
var night_energy := 0.2

# Referencje do obiektów
onready var sun := $"%Sun"
onready var moon := $"%Moon"
onready var world_environment := $"%Env"

# Czas faz
var morning_duration := 0.25  # 25% dnia
var afternoon_duration := 0.4  # 40% dnia
var sunset_duration := 0.15  # 15% dnia
var night_duration := 0.2  # 20% nocy

func _process(delta):
	# Aktualizacja kąta Słońca i Księżyca
	sun_angle += (360.0 / day_length) * delta
	moon_angle += (360.0 / day_length) * delta

	if sun_angle > 360.0:
		sun_angle -= 360.0

	if moon_angle > 360.0:
		moon_angle -= 360.0

	# Ustawienie rotacji Słońca i Księżyca
	sun.rotation_degrees = Vector3(sun_angle, 0, 0)
	moon.rotation_degrees = Vector3(moon_angle, 0, 0)

	# Aktualizacja kolorów i intensywności
	var sun_phase := sun_angle / 360.0
	update_lighting(sun_phase)

func update_lighting(phase: float):
	# Poranek: wschód słońca (0 - 0.25)
	if phase < morning_duration:
		var t := phase / morning_duration
		sun.light_color = night_light_color.linear_interpolate(morning_light_color, t)
		sun.light_energy = lerp(night_intensity, morning_intensity, t)
		update_environment(morning_light_color, t, night_energy, morning_energy)

	# Popołudnie: pełnia dnia (0.25 - 0.65)
	elif phase < (morning_duration + afternoon_duration):
		var t := (phase - morning_duration) / afternoon_duration
		sun.light_color = morning_light_color.linear_interpolate(afternoon_light_color, t)
		sun.light_energy = lerp(morning_intensity, afternoon_intensity, t)
		update_environment(afternoon_light_color, t, morning_energy, afternoon_energy)

	# Zachód słońca: długie cienie (0.65 - 0.80)
	elif phase < (morning_duration + afternoon_duration + sunset_duration):
		var t := (phase - morning_duration - afternoon_duration) / sunset_duration
		sun.light_color = afternoon_light_color.linear_interpolate(sunset_light_color, t)
		sun.light_energy = lerp(afternoon_intensity, sunset_intensity, t)
		update_environment(sunset_light_color, t, afternoon_energy, sunset_energy)

	# Noc: chłodne światło księżyca (0.80 - 1.0)
	else:
		var t := (phase - morning_duration - afternoon_duration - sunset_duration) / night_duration
		sun.light_color = sunset_light_color.linear_interpolate(night_light_color, t)
		sun.light_energy = lerp(sunset_intensity, night_intensity, t)
		update_environment(night_light_color, t, sunset_energy, night_energy)

	# Księżyc
	if phase > 0.65 or phase < 0.2:
		moon.visible = true
		moon.light_energy = lerp(night_intensity, morning_intensity, 1.0 - phase)
	else:
		moon.visible = false

# Aktualizacja parametrów WorldEnvironment, w tym background_energy
func update_environment(color: Color, t: float, energy_start: float, energy_end: float):
	var sky_color := color.linear_interpolate(night_light_color, t * 0.5)
	world_environment.environment.background_color = sky_color
#	world_environment.environment.fog_color = sky_color
	world_environment.environment.background_energy = lerp(energy_start, energy_end, t)
