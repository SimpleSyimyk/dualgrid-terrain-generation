extends Node2D
class_name ProceduralGenerator
@export_node_path("Camera2D") var camera_path: NodePath
@export var generation_params: GeneratorResource
@export_group("Distance and size")
@export var render_distance: Vector2 = Vector2(1600, 900)
@export var tile_size: Vector2 = Vector2(32, 32)
@export_range(0, 1, 0.0001) var frecuency: float = 0.001

var camera: Camera2D
var terrain_noise: FastNoiseLite = FastNoiseLite.new()
var biome_grids: Dictionary = {}
var loaded_chunks: Dictionary[Vector2i, String] = {}
var previous_camera_position: Vector2i = Vector2i(0,0)

func _ready() -> void:
	position = Vector2(16,16)
	render_distance = _position_to_coords(render_distance)
	_initialize_noise_generator()
	_initialize_biome_grids()
	_initial_camera()

func _physics_process(_delta: float) -> void:
	_handle_chunk_generation()

func _initial_camera() -> void:
	camera = get_node_or_null(camera_path)
	previous_camera_position = Vector2i(camera.position) + Vector2i(1,1)

func _handle_chunk_generation() -> void:
	var current_camera_chunk: Vector2i = _position_to_coords(camera.global_position)
	if current_camera_chunk != previous_camera_position:
		previous_camera_position = current_camera_chunk
		_update_chunks_around_camera(current_camera_chunk)

func _initialize_noise_generator(seed_value: int = 0) -> void:
	terrain_noise.seed = seed_value
	terrain_noise.frequency = frecuency
	terrain_noise.fractal_type = FastNoiseLite.FRACTAL_NONE

func _initialize_biome_grids() -> void:
	for biome_name: String in generation_params.biome_names:
		var path: String = generation_params.get_biom_path(biome_name)
		var biome_grid: DualGrid = get_node_or_null(path)
		if biome_grid != null:
			biome_grids[biome_name] = biome_grid



func _update_chunks_around_camera(camera_chunk_coords: Vector2) -> void:
	var render_half_width: int = int(floor(render_distance.x / 2.0))
	var render_half_height: int = int(floor(render_distance.y / 2.0))
	_load_chunks_in_range(render_half_width, render_half_height, camera_chunk_coords)
	_unload_distant_chunks(render_half_width, render_half_height, camera_chunk_coords)

func _unload_distant_chunks(render_half_width: int, render_half_height: int, camera_chunk_coords: Vector2) -> void:
	var left_border: int = int(floor(camera_chunk_coords.x - 1 - render_half_width))
	var right_border: int = int(floor(camera_chunk_coords.x + 1 + render_half_width))
	var top_border: int = int(floor(camera_chunk_coords.y - 1 - render_half_height))
	var bottom_border: int = int(floor(camera_chunk_coords.y + 1 + render_half_height))

	for x in range(left_border, right_border + 1):
		_unload_chunk(Vector2(x, top_border))
		_unload_chunk(Vector2(x, bottom_border))

	for y in range(top_border, bottom_border + 1):
		_unload_chunk(Vector2(left_border, y))
		_unload_chunk(Vector2(right_border, y))

func _unload_chunk(chunk_coords: Vector2i) -> void:
	if loaded_chunks.has(chunk_coords):
		var chunk_biome_name: String = loaded_chunks[chunk_coords]
		if biome_grids.has(chunk_biome_name):
			biome_grids[chunk_biome_name].auto_erase(chunk_coords)
		loaded_chunks.erase(chunk_coords)


func _load_chunks_in_range(render_half_width: int, render_half_height: int, camera_chunk_coords: Vector2) -> void:
	for x_offset in range(-render_half_width, render_half_width): 
		for y_offset in range(-render_half_height, render_half_height):
			var target_chunk_coords: Vector2i = Vector2i(int(camera_chunk_coords.x + x_offset), 
														 int(camera_chunk_coords.y + y_offset))
			var biome_name: String = _determine_biome_at_coordinates(target_chunk_coords)
			if biome_grids.has(biome_name):
				loaded_chunks[target_chunk_coords] = biome_name
				biome_grids[biome_name].auto_tile(target_chunk_coords)

func _determine_biome_at_coordinates(chunk_coords: Vector2) -> String:
	var terrain_parameters: Dictionary = _get_noise_params(chunk_coords)
	var min_score: int = 10000
	var result: String = ''
	
	for biome_name: String in generation_params.biome_names:
		var current_similar: int = _how_similar_params(biome_name, terrain_parameters)
		if current_similar < min_score:
			min_score = current_similar
			result = biome_name
	return result

func _how_similar_params(biome_name: String, terrain_params: Dictionary) -> int:
	var biome_reference_params: Dictionary = generation_params.get_params(biome_name)
	var total_difference_score: int = 0
	
	for parameter_name: String in biome_reference_params.keys():
		total_difference_score += int(abs(biome_reference_params[parameter_name] - terrain_params[parameter_name]))
	
	return total_difference_score

func _get_noise_params(chunk_coords: Vector2) -> Dictionary:
	var result: Dictionary[String, int] = {}
	for index in range(generation_params.param_names.size()):
		result[generation_params.param_names[index]] = _get_noise_value(chunk_coords.x, chunk_coords.y, index * 1000)
	return result

func _get_noise_value(x_coordinate: float, y_coordinate: float, z_offset: float) -> int:
	return abs(floor(terrain_noise.get_noise_3d(x_coordinate, y_coordinate, z_offset) * 10))

func _position_to_coords(world_position: Vector2) -> Vector2i:
	var chunk_x: int = floor(world_position.x / tile_size.x)
	var chunk_y: int = floor(world_position.y / tile_size.y)
	return Vector2i(chunk_x, chunk_y)
