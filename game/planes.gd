extends Node

var plane_textures := []

func _ready():
	call_deferred( "_prepare_plane_textures" )

func _prepare_plane_textures():
	# Load files
	var files = []
	var dir = Directory.new()
	dir.open( "res://assets/planes" )
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with( "." ) and not file.ends_with( "import" ):
			files.append( file )
	
	dir.list_dir_end()
	for fname in files:
		plane_textures.append( load( "res://assets/planes/%s" % [ fname ] ) )
	

	

func get_random_texture() -> Texture:
	return plane_textures[ randi() % plane_textures.size() ]
