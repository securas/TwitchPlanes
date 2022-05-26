extends Node2D

const TILEMAP_WIDTH = 150
const TILEMAP_HEIGHT = 110
var noise : OpenSimplexNoise
onready var terrain : TileMap  = $terrain
onready var water : TileMap  = $water
var cur_y = 0.0
var ylst := 1

func _ready() -> void:
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 3
	noise.period = 20.0
	noise.persistence = 0.8
	call_deferred( "_initialize" )

func _initialize():
	var delta : float = 1.0 / 60.0
	while( cur_y > -TILEMAP_HEIGHT + 2 ):
		_set_coordinate( cur_y )
		cur_y -= delta

func _physics_process(delta: float) -> void:
	_set_coordinate( cur_y )
	cur_y -= delta * 1
	

func _set_coordinate( y : float ):
	var yint = int( y )
	if yint != ylst:
		_set_terrain( yint )
		ylst = yint
	terrain.position.y = -( y + 2 ) * 16
	water.position.y = -( y + 2 ) * 16

func _set_terrain( y : int ) -> void:
	for x in range( -2, TILEMAP_WIDTH + 1 ):
# warning-ignore:integer_division
# warning-ignore:integer_division
		var n = noise.get_noise_2d( int( x ) / 2, int( y ) / 2 )
		if n > 0:
			terrain.set_cell( x, y, 0 )
		else:
			terrain.set_cell( x, y, -1 )
		terrain.set_cell( x, y + TILEMAP_HEIGHT, -1 )
		water.set_cell( x, y, 1 )
		water.set_cell( x, y + TILEMAP_HEIGHT, -1 )
	terrain.update_bitmask_region( Vector2( 0, y ), Vector2( TILEMAP_WIDTH, y ) )
	water.update_bitmask_region( Vector2( 0, y ), Vector2( TILEMAP_WIDTH, y ) )

func _shift():
	for y in range( TILEMAP_HEIGHT, -3, -1 ):
		for x in range( TILEMAP_WIDTH ):
			terrain.set_cell( x, y, terrain.get_cell( x, y - 1 ) )

