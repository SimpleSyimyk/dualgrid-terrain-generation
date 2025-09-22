# Procedural World Generator for Godot 4.5.stable

This project provides a procedural world generation system for Godot 4.5 using a **chunk-based approach**, **FastNoiseLite**, and **biome management** with dynamic loading and unloading of chunks.

---

## Features

- **Chunk-based procedural generation** with dynamic loading/unloading.
- **Support for multiple biomes** with individual parameters.
- **Batch processing** of chunks for smooth runtime performance.
- Configurable **tile size**, **render radius**, and **noise frequency**.
- Fully customizable **DualGrid** system for biome tiling.
- **TileSets must follow the order** shown in `example/tiles` for correct biome rendering.

---

## Components

### `ProceduralGenerator.gd`
- Main node (`Node2D`) responsible for:
  - Tracking camera position.
  - Loading/unloading chunks dynamically.
  - Generating terrain using noise and biome parameters.
- Key exported properties:
  - `camera_path: NodePath` – camera node reference.
  - `resource_world_generator: GeneratorResource` – generator resource.
  - `render_radius: Vector2i` – how many chunks to load around the camera.
  - `tile_size: Vector2` – size of individual tiles.
  - `frecuency: float` – noise frequency.

---

### `DualGridResource.gd`
- Resource for a single biome.
- Stores biome parameters as a dictionary (`params: Dictionary[String, float]`).
- Auto-generates property list in Inspector for easy editing.
- Functions:
  - `get_params()` – returns biome parameters as integers.
  - `init_params(keys: Array[String])` – initializes missing parameters.

---

### `GeneratorResource.gd`
- Main resource holding all biomes and generation settings.
- Properties:
  - `tiles: Array[DualGridResource]` – optional tile references (must follow the order in `example/tiles`).
  - `params_names: Array[String]` – names of terrain parameters.
  - `biomes_names: Array[String]` – list of biome names.
  - `biomes: Dictionary[String, DualGridResource]` – biome resources.
- Functions:
  - `get_biomes_params_cache()` – returns biome parameters as `PackedByteArray` for fast access.
  - `get_boimes_pathes()` – returns dictionary of biome node paths.
  - `_generate_biomes_resource()` – creates missing `DualGridResource` for new biomes.

---

### `ChunkLoader.gd`
- Handles **batch loading** of chunks.
- Determines the best biome for each chunk using **parameter similarity** and noise values.
- Functions:
  - `process_batch()` – generates a batch of chunks.
  - `_get_biom_name_at_coords()` – selects the biome based on noise and parameters.
  - `_get_params_similar_score()` – calculates similarity between chunk noise values and biome parameters.

---

### `ChunkUnloader.gd`
- Handles **batch unloading** of chunks outside the render radius.
- Removes tiles from `DualGrid` nodes.
- Function:
  - `process_batch()` – erases a batch of chunks.

---

### `DualGrid.gd`
- `TileMapLayer` node used to render a single biome.
- Functions:
  - `auto_tile(coords: Vector2i)` – updates tiles based on chunk offsets.
  - `auto_erase(coords: Vector2i)` – removes tiles when unloading chunks.
- Uses a 2x2 **offset mask system** to manage tile placement efficiently.

---

## Usage

1. Add `ProceduralGenerator` node to your scene.
2. Assign a `Camera2D` node to `camera_path`.
3. Create a `GeneratorResource` with your biomes and parameter names.
4. Assign it to `resource_world_generator`.
5. Make sure your **TileSets follow the order shown in `example/tiles`**.
6. Set `render_radius`, `tile_size`, and `frequency`.
7. Run the scene—chunks will load/unload automatically as the camera moves.

Example:

```gdscript
var generator = $ProceduralGenerator
generator.render_radius = Vector2i(20, 12)
generator.tile_size = Vector2(32, 32)
generator.frecuency = 0.005
