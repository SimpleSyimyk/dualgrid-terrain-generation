extends Node2D
class_name ProceduralGenerator
@export_node_path("Camera2D") var camera_path: NodePath
@export var resource_world_generator: GeneratorResource
@export_group("Render settings")
@export var render_radius: Vector2i = Vector2i(16, 9)
@export var tile_size: Vector2 = Vector2(32, 32)
@export_range(0, 1, 0.001) var frecuency: float = 0.001

var camera: Camera2D
var previous_camera_position: Vector2i = Vector2i(0,0)

var terrain_noise: FastNoiseLite = FastNoiseLite.new()

var biomes_nodes: Dictionary[String, DualGrid] = {}
var loaded_chunks: Dictionary[Vector2i, String] = {}

var bioms_params_cache: Dictionary[int, PackedByteArray] = {}
var noise_buffer: PackedByteArray = PackedByteArray()
var biomes_names: Array[String] = []
var stashed_loaders: Array[ChunkLoader] = []
var stashed_unloaders: Array[ChunkUnloader] = []
var batch_size: int = 50
var params_names: Array[String] = []

var can_load: bool = true

func _ready() -> void:
	self.global_position = Vector2(16,16)
	_initialize_noise()
	_initialize_biomes()
	_initial_camera()
	
	
func _process(_delta: float) -> void:
	if stashed_loaders.size() != 0 and can_load: 
		for loader in stashed_loaders:
			var is_completed = loader.process_batch()
			if not is_completed: continue
			_get_loaded_chunks(loader.loaded_chunks)
			stashed_loaders.erase(loader)
			loader = null
		can_load = false
	if stashed_unloaders.size() != 0 and not can_load:
		for unloader in stashed_unloaders:
			var is_completed = unloader.process_batch()
			if not is_completed: continue
			loaded_chunks = loaded_chunks
			stashed_unloaders.erase(unloader)
			unloader = null
		can_load = true

func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % 60 == 0:
		_handle_chunk_generation()

func _get_loaded_chunks(chunks_dict: Dictionary[Vector2i, String]) -> void:
	for key in chunks_dict.keys():
		loaded_chunks[key] = chunks_dict[key]


func _handle_chunk_generation() -> void:
	var load_coords: Vector2i = _position_to_coords(camera.global_position)
	if load_coords != previous_camera_position:
		previous_camera_position = load_coords
		var current_chunk_area: Array[Vector2i] = _make_load_distance(load_coords)
		
		_load_chunks_in_range(current_chunk_area)
		_unload_distant_chunks(current_chunk_area)


func _unload_distant_chunks(to_load_chunks: Array[Vector2i]) -> void:
	stashed_unloaders.append(ChunkUnloader.new(
		to_load_chunks, 
		loaded_chunks, 
		biomes_nodes, 
		noise_buffer,
		biomes_names,
		params_names,
		terrain_noise,
		bioms_params_cache))

func _load_chunks_in_range(to_load_chunks: Array[Vector2i]) -> void:
	
	stashed_loaders.append(ChunkLoader.new(
		to_load_chunks, 
		loaded_chunks, 
		biomes_nodes, 
		noise_buffer,
		biomes_names,
		params_names,
		terrain_noise,
		bioms_params_cache))


func _make_load_distance(load_coords: Vector2i) -> Array[Vector2i]:
	var chunks_arr: Array[Vector2i] = []
	for x in range(-render_radius.x, render_radius.x): 
		for y in range(-render_radius.y, render_radius.y):
			var chunk: Vector2i = load_coords + Vector2i(x, y)
			chunks_arr.append(chunk) 
			#if loaded_chunks.has(chunk): continue
			#loaded_chunks[chunk] = ""
	return chunks_arr


func _position_to_coords(world_position: Vector2) -> Vector2i:
	var coord_x: int = int(world_position.x / tile_size.x)
	var coord_y: int = int(world_position.y / tile_size.y)
	return Vector2i(coord_x, coord_y)




func _initial_camera() -> void:
	camera = get_node_or_null(camera_path)
	previous_camera_position = Vector2i(camera.position) + Vector2i(1,1)

func _initialize_noise(seed_value: int = 0) -> void:
	terrain_noise.seed = seed_value
	terrain_noise.frequency = frecuency
	terrain_noise.fractal_type = FastNoiseLite.FRACTAL_NONE

func _initialize_biomes() -> void:
	biomes_names = resource_world_generator.biomes_names
	params_names = resource_world_generator.params_names
	biomes_nodes = _get_tile_nodes_dict()
	noise_buffer.resize(params_names.size())
	
	bioms_params_cache = resource_world_generator.get_biomes_params_cache()


func _get_tile_nodes_dict() -> Dictionary[String, DualGrid]:
	var pathes: Dictionary[String, NodePath] = resource_world_generator.get_boimes_pathes()
	var nodes: Dictionary[String, DualGrid] = {}
	
	for biome_name: String in pathes.keys():
		var path: String = pathes[biome_name]
		var biome_node: DualGrid = get_node_or_null(path)
		
		if biome_node == null: continue
		nodes[biome_name] = biome_node
	
	return nodes
