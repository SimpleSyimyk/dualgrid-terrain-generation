extends TileMapLayer
class_name DualGrid

const OFFSETS: Array[Vector2i] = [
	Vector2i(-1, -1),
	Vector2i( 0, -1),
	Vector2i(-1,  0),
	Vector2i( 0,  0),
]
const MASKS: Array[int] = [0b0001, 0b0010, 0b0100, 0b1000]

var load_cells: Dictionary = {}

func auto_erase(coords: Vector2i) -> void:
	if load_cells.has(coords): 
		for coord in OFFSETS:
			erase_cell(coords + coord)
		load_cells.erase(coords)

func auto_tile(coords: Vector2i) -> void:
	var lc := load_cells
	for i in 4:
		var pos := coords + OFFSETS[i]
		var mask := MASKS[i]
		var prev : int = lc.get(pos, 0)
		var value : int = prev | mask
		lc[pos] = value
		set_cell(pos, 0, Vector2i(value - 1, 0), 0)
