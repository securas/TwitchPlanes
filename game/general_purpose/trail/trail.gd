  extends Line2D

const SCREEN_VEL = 300.0

var point_count = 30
var is_active := true
onready var parent = get_parent()



func _ready():
	set_as_toplevel(true)


func _physics_process(_delta):
	add_point( parent.global_position )
	if points.size() > point_count:
		remove_point(0)
	
	for idx in range( points.size() ):
		set_point_position( idx, points[idx] + Vector2.DOWN * SCREEN_VEL * _delta )
		
