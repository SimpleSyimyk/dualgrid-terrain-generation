class_name ChunkLoader extends Node

var batch_size: int = 50
var to_load_chunk: Array[Vector2i] = []
var loaded_chunks: Dictionary[Vector2i, String] = {}
var current_index: int = 0
var biome_nodes: Dictionary[String, DualGrid]
var noise_buffer: PackedByteArray
var biome_names: Array[String] = []
var params_names: Array[String] = []
var terrain_noise: FastNoiseLite = null
var biomes_params_cache: Dictionary[int, PackedByteArray] = {}
var loaded_chunks_keys: Array[Vector2i] = []


func _init(
	_to_load_chunk: Array[Vector2i],
	_loaded_chunks: Dictionary[Vector2i, String],
	_biome_nodes: Dictionary[String, DualGrid],
	_noise_buffer: PackedByteArray,
	_biome_names: Array[String],
	_params_names: Array[String],
	_terrain_noise: FastNoiseLite,
	_biomes_params_cache: Dictionary[int, PackedByteArray]
	
	
	):
	to_load_chunk = _to_load_chunk
	loaded_chunks = _loaded_chunks
	biome_nodes = _biome_nodes
	noise_buffer = _noise_buffer
	biome_names = _biome_names
	params_names = _params_names
	terrain_noise = _terrain_noise
	biomes_params_cache = _biomes_params_cache
	loaded_chunks_keys = loaded_chunks.keys()
	
	
func process_batch():
	var end_index = min(current_index + batch_size, to_load_chunk.size())
	
	_generate_in_range(current_index, end_index)
	
	current_index = end_index 
	if current_index >= to_load_chunk.size():
		return true
	return false
		
	
func _generate_in_range(start: int, end: int) -> void:
	for i in range(start, end):
		var target_chunk_coords = to_load_chunk[i] as Vector2i
		var biome_name: String = _get_biom_name_at_coords(target_chunk_coords)
		loaded_chunks[target_chunk_coords] = biome_name
		biome_nodes[biome_name].auto_tile(target_chunk_coords)


func _get_biom_name_at_coords(chunk_coords: Vector2i) -> String:
	_get_noise_params(chunk_coords, noise_buffer)
	var min_score: int = 10000
	var best_index: int = -1
	for biom_index in biome_names.size():
		var current_similar: int = _get_params_similar_score(biom_index, noise_buffer)
		if current_similar < min_score:
			min_score = current_similar
			best_index = biom_index
	return biome_names[best_index] if best_index != -1 else ""
	
	
func _get_noise_params(chunk_coords: Vector2i, out_buffer: PackedByteArray) -> void:

	for index in range(params_names.size()):
		out_buffer[index] = _get_noise_value(chunk_coords, index * 1000)

func _get_noise_value(coords: Vector2i, index: int) -> int:
	coords += Vector2i(index, index)
	var value: int = int(10 * terrain_noise.get_noise_2dv(coords))
	return abs(value)

func _get_params_similar_score(biome_index: int, terrain_params_buffer: PackedByteArray) -> int:
	var total_difference_score: int = 0
	var biome_params: PackedByteArray = biomes_params_cache[biome_index]
	for index in terrain_params_buffer.size():
		total_difference_score += abs(biome_params[index] - terrain_params_buffer[index])
	return total_difference_score
