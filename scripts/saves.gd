extends Node
@export var points : Array[float]
const SAVE_FOLDER : String = "user://saved_settings/"

func _ready() -> void:
	DirAccess.make_dir_absolute(SAVE_FOLDER)
	var node = Node.new()
	add_child(node)
	node.set_script(load("res://scripts/saver_node.gd"))
	node.add_to_group(SaverNode.SAVER_NODE_GROUP)
	load_data()
	
	##MUSIC
	#var music_node = AudioStreamPlayer.new()
	#add_child(music_node)
	#music_node.autoplay = 1
	#music_node.bus = "Music"
	#music_node.stream = preload("")

##SAVING FUNCTIONS
func get_save_file_path() -> String:
	return SAVE_FOLDER + str("settings.res")

func save_data() -> void:
	var new_save = SaveData.new()
	for saver : SaverNode in get_tree().get_nodes_in_group(SaverNode.SAVER_NODE_GROUP):
		var node_path = get_path_to(saver)
		new_save.data[node_path] = saver.get_save_dict()
	ResourceSaver.save(new_save, get_save_file_path())

func load_data() -> void:
	if not FileAccess.file_exists(get_save_file_path()):
		print("WARN: a save-file does not exist, creating a new one...")
		points = []
		save_data()
		return
	var loaded_save = ResourceLoader.load(get_save_file_path()) as SaveData
	for path in loaded_save.data:
		var saver_node = get_node_or_null(path)
		if saver_node:
			saver_node.apply_save_dict(loaded_save.data[path])
