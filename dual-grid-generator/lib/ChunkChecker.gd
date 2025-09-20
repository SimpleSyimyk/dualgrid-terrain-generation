class_name ChunkChecker extends Node

var batch_size : int
var chunk_arr : Array[Vector2i]
var loaded_chunks : Dictionary
var current_index : int = 0
var biome_grids
var noise_buffer
var biome_names
var generation_params
var terrain_noise
var biom_grid_resource_param_cache : Dictionary[int, PackedInt32Array] = {}
var result

func _init(
	_chunk_arr: Array[Vector2i],
	_batch_size: int,
	_loaded_chunks : Dictionary,
	_biome_grids,
	_noise_buffer,
	_biome_names,
	_generation_params,
	_terrain_noise,
	_biom_grid_resource_param_cache
	
	):
	batch_size = _batch_size
	chunk_arr = _chunk_arr
	loaded_chunks = _loaded_chunks
	biome_grids = _biome_grids
	noise_buffer = _noise_buffer
	biome_names = _biome_names
	generation_params = _generation_params
	terrain_noise = _terrain_noise
	biom_grid_resource_param_cache = _biom_grid_resource_param_cache
	
	
func process_batch():
	var end_index = min(current_index + batch_size, chunk_arr.size())

	for i in range(current_index, end_index):
		var target_chunk_coords = chunk_arr[i] as Vector2i
		if target_chunk_coords in loaded_chunks:
			# Optional: check neighbors for completeness
			if _chunk_neighbors_complete(target_chunk_coords):
				continue
		var biome_name: String = _determine_biome_at_coordinates(target_chunk_coords)
		if biome_grids.has(biome_name):
			loaded_chunks[target_chunk_coords] = biome_name
			biome_grids[biome_name].auto_tile(target_chunk_coords)
	
	current_index = end_index 
	if current_index >= chunk_arr.size():
		return true
	return false
		
	
func _chunk_neighbors_complete(chunk_coords : Vector2i):
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if Vector2i(chunk_coords.x + dx, chunk_coords.y + dy) not in loaded_chunks:
				return false
	return true
	
	
func _determine_biome_at_coordinates(chunk_coords: Vector2i) -> String:
	_get_noise_params(chunk_coords, noise_buffer)
	var min_score: int = 10000
	var best_index := -1
	for biom_index in biome_names.size():
		var current_similar: int =  _how_similar_params(biom_index, noise_buffer)
		if current_similar < min_score:
			min_score = current_similar
			best_index = biom_index
	return biome_names[best_index] if best_index != -1 else ""
	
	
func _get_noise_params(chunk_coords: Vector2i, out_buffer: PackedInt32Array) -> void:
	for index in range(generation_params.param_names.size()):
		out_buffer[index] = _get_noise_value(chunk_coords.x, chunk_coords.y, index * 1000)

func _get_noise_value(x_coordinate: int, y_coordinate: int, z_offset: int) -> int:
	var value: int = floor(terrain_noise.get_noise_3d(x_coordinate, y_coordinate, z_offset) * 10)
	return value if value > 0 else -value

func _how_similar_params(biome_index: int, terrain_params_buffer: PackedInt32Array) -> int:
	var total_difference_score: int = 0
	var biome_params := biom_grid_resource_param_cache[biome_index]
	for index in terrain_params_buffer.size():
		total_difference_score += abs(biome_params[index] - terrain_params_buffer[index])
	return total_difference_score
