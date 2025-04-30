extends Node

const MAP_SIZE = Vector2(40, 40)
const NUM_CONTINENTS = 3
const NOISE_SCALE = 10.0
const LAND_THRESHOLD = 0.0  # Hałas wyznaczający ląd
const CONTINENT_RADIUS_FACTOR = 0.7

var noise: FastNoiseLite
var continent_centers = []

func _ready():
	randomize()
	setup_noise()
	continent_centers = generate_continent_centers(NUM_CONTINENTS)
	var map = generate_map()
	visualize_map(map)

# Ustawienie hałasu
func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.fractal_octaves = 4
	noise.persistence = 0.5
	noise.lacunarity = 2.0

# Generowanie centrów kontynentów
func generate_continent_centers(num_centers: int) -> Array:
	var centers = []
	while centers.size() < num_centers:
		var point = Vector2(randf_range(0, MAP_SIZE.x), randf_range(0, MAP_SIZE.y))
		var valid = true
		for center in centers:
			if center.distance_to(point) <= MAP_SIZE.x / num_centers:
				valid = false
				break
		if valid:
			centers.append(point)
	return centers

# Generowanie maski kontynentu na podstawie hałasu i dystansu
func generate_continent_mask(center: Vector2, scale: float) -> Dictionary:
	var mask = {}
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			var position = Vector2(x, y)
			var dist = position.distance_to(center)
			var noise_value = noise.get_noise_2d(x / scale, y / scale)
			if noise_value > LAND_THRESHOLD and dist < MAP_SIZE.x / NUM_CONTINENTS * CONTINENT_RADIUS_FACTOR:
				mask[position] = true  # Ląd
			else:
				mask[position] = false  # Woda
	return mask

# Przypisanie biomów w obrębie lądu
func assign_biomes(mask: Dictionary) -> Dictionary:
	var biomes = {}
	for position in mask.keys():
		if mask[position]:  # Jeśli to ląd
			var biome_noise = noise.get_noise_2d(position.x / 10.0, position.y / 10.0)
			if biome_noise > 0.6:
				biomes[position] = "mountain"  # Góry
			elif biome_noise > 0.3:
				biomes[position] = "plain"  # Równiny
			else:
				biomes[position] = "forest"  # Lasy
		else:
			biomes[position] = "water"  # Woda
	return biomes

# Generowanie pełnej mapy
func generate_map() -> Dictionary:
	var map = {}
	for center in continent_centers:
		var continent_mask = generate_continent_mask(center, NOISE_SCALE)
		var continent_biomes = assign_biomes(continent_mask)

		# Ręczne dodanie kluczy i wartości do mapy
		for key in continent_biomes.keys():
			map[key] = continent_biomes[key]

	return map

# Wizualizacja mapy w konsoli
func visualize_map(map: Dictionary):
	for y in range(MAP_SIZE.y):
		var row = ""
		for x in range(MAP_SIZE.x):
			var biome = map.get(Vector2(x, y), "water")
			if biome == "mountain":
				row += "^"  # Góry
			elif biome == "plain":
				row += "."  # Równiny
			elif biome == "forest":
				row += "*"  # Lasy
			else:
				row += "~"  # Woda
		print(row)
