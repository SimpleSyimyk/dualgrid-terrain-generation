extends TileMapLayer
class_name DualGrid



var load_cells: Dictionary = {}

func auto_erase(coords: Vector2) -> void:
	if load_cells.has(coords): 
		var cell_coords: Array[Vector2] = [
			Vector2(1, 1),
			Vector2(0, 1),
			Vector2(1, 0),
			Vector2(0, 0)]
			
		for coord in cell_coords:
			var erase_coord: Vector2 = coords - coord
			erase_cell(erase_coord)
			
		load_cells.erase(coords)

func auto_tile(coords: Vector2) -> void:
	var corners := {
		coords - Vector2(1, 1): 0b0001,
		coords - Vector2(0, 1): 0b0010,
		coords - Vector2(1, 0): 0b0100,
		coords - Vector2(0, 0): 0b1000,
	}
	for pos in corners:
		_apply_cell(pos, corners[pos])

func _apply_cell(coords: Vector2, value: int) -> void:
	if not load_cells.has(coords):
		load_cells[coords] = value
	else:
		load_cells[coords] |= value
	var x: int = load_cells[coords] - 1

	set_cell(coords, 0, Vector2(x, 0), 0)
