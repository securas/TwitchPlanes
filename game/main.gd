extends Node2D


onready var viewport = $background/terrain_viewport_container/viewport
onready var terrain_container = $background/terrain_viewport_container
onready var clouds = $clouds

var background_state := 0

func _ready() -> void:
#	get_tree().get_root().set_transparent_background(true)
	var _ret = get_viewport().connect( "size_changed", self, "_on_viewport_size_changed" )
	_update_screen_stretch()


func _on_viewport_size_changed():
	var cur_vsize = get_viewport_rect().size
	Params.screen_size = cur_vsize
	print( "New Window Size: ", cur_vsize )
	viewport.size = cur_vsize
	terrain_container.rect_size = cur_vsize


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed( "btn_zoom_in" ):
		Params.screen_stretch += 0.1
		Params.screen_stretch = clamp( Params.screen_stretch, 0.5, 4 )
		_update_screen_stretch()
	if Input.is_action_just_pressed( "btn_zoom_out" ):
		Params.screen_stretch -= 0.1
		Params.screen_stretch = clamp( Params.screen_stretch, 0.7, 4 )
		_update_screen_stretch()
	if Input.is_action_just_pressed( "btn_formation" ):
		print( "Changing formation behavior" )
		Params.formation_behavior = ( Params.formation_behavior + 1 ) % ( Params.FormationBehaviors.size() )
	if Input.is_action_just_pressed( "btn_background" ):
		background_state = ( background_state + 1 ) % 3
		match background_state:
			0:
				get_tree().get_root().set_transparent_background( false )
				$background.show()
				$clouds.show()
			1:
				get_tree().get_root().set_transparent_background( true )
				$background.hide()
				$clouds.show()
			2:
				get_tree().get_root().set_transparent_background( true )
				$background.hide()
				$clouds.hide()
		

func _update_screen_stretch():
	get_tree().set_screen_stretch(
			SceneTree.STRETCH_MODE_DISABLED,
			SceneTree.STRETCH_ASPECT_IGNORE,
			Vector2.ZERO,
			Params.screen_stretch
		)
	viewport.size = Params.screen_size
	terrain_container.rect_size = Params.screen_size
	
	OS.set_screen_orientation( OS.SCREEN_ORIENTATION_PORTRAIT )
	


