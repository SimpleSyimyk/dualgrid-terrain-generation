class_name ChunkUnloader extends Node

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
var biomes_keys: Array[Vector2i] = []


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
	biomes_keys = loaded_chunks.keys()
	
func process_batch():
	var end_index: int = min(current_index + batch_size, biomes_keys.size())

	for i in range(current_index, end_index):
		var target_chunk_coords: Vector2i = biomes_keys[i]
		if target_chunk_coords in to_load_chunk: continue
		if not loaded_chunks.has(target_chunk_coords): continue
		var biome_name: String = loaded_chunks[target_chunk_coords]
		loaded_chunks.erase(target_chunk_coords)
		biome_nodes[biome_name].auto_erase(target_chunk_coords)
	
	current_index = end_index 
	if current_index >= to_load_chunk.size():
		return true
	return false
