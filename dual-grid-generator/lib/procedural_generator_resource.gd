@tool
extends Resource
class_name GeneratorResource

@export_group("Distance and Size")
var tiles: Array[DualGridResource]
@export_group('Setup generator')

@export var param_names: Array[String] = []
@export var biome_names: Array[String] = []
@export_tool_button("Setup biomes")
var btn: Callable = inspector_button
@export_group("Bioms")
var biomes: Dictionary[String, DualGridResource] = {}

func inspector_button() -> void:
	notify_property_list_changed()
	_generate_biomes()

func get_biom_path(biom_name: String) -> String:
	if biomes.has(biom_name):
		return biomes[biom_name].path
	return ""

func get_params(biom_name: String) -> Dictionary[String, int]:
	if biomes.has(biom_name):
		var biom: DualGridResource = biomes[biom_name]
		return biom.get_params()
	return {}

func _generate_biomes():
	for name in biome_names:
		if not biomes.has(name):
			var biome := DualGridResource.new()
			biome.biom_name = name
			biome.init_params(param_names) 
			biomes[name] = biome
		else: 
			var biome: DualGridResource = biomes[name]
			biome.init_params(param_names)

func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []
	for name in biome_names:
		props.append({
			"name": "biom_%s" % name,
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Biom",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return props

func _get(property: StringName):
	if property.begins_with("biom_"):
		var key = property.substr(5)
		return biomes.get(key, null)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("biom_") and value is DualGridResource:
		var key = property.substr(5)
		biomes[key] = value
		return true
	return false
