extends TileMapLayer
class_name DualGrid



const OFFSETS: Dictionary[Vector2i, int] = {
	Vector2i(0, 0): 0b0001,
	Vector2i(1, 0): 0b0010,
	Vector2i(0, 1): 0b0100,
	Vector2i(1, 1): 0b1000,
}

var load_cells: Dictionary[Vector2i, int] = {}

func auto_erase(coords: Vector2i) -> void:
	if load_cells.has(coords): 
		for offset_coord in OFFSETS:
			erase_cell(coords + offset_coord)
		load_cells.erase(coords)

func auto_tile(coords: Vector2i) -> void:
	
	for key in OFFSETS.keys():
		var pos: Vector2i = coords + key
		var mask: int = OFFSETS[key]
		var prev: int = load_cells.get(pos, 0)
		if prev == 15 and mask == 15: continue 
		var value: int = prev | mask
		load_cells[pos] = value
		set_cell(pos, 0, Vector2i(value - 1, 0))
