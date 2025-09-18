@tool
extends Resource
class_name DualGridResource
@export_group("Dont touch!!!")
@export var params: Dictionary[String, float] = {}
@export_category("")
var biom_name: String = ""
#@export var biom_dual_grid: NodePath = "null"
@export_node_path("DualGrid") var path: NodePath = ""

func get_params() -> Dictionary[String, int]:
	var result: Dictionary[String, int] = {}
	for key in params.keys():
		result[key] = int(params[key])
	return result

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	for key in params.keys():
		props.append({
			"name": key,
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,10,1",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return props

func init_params(keys: Array[String]):
	var result: Dictionary[String, float] = {}
	for key in keys:
		if not params.has(key):
			result[key] = 0 
		else:
			result[key] = params[key]
	params = result
	notify_property_list_changed()

func _get(property: StringName) -> Variant:
	if params.has(property):
		return params[property]
	return null

func _set(property: StringName, value: Variant) -> bool:
	if params.has(property):
		params[property] = value
		return true
	return false
