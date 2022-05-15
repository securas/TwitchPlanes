extends Node2D
class_name PlaneFormation


var debug := true
var formation := []
var user_counter:= 1



func _physics_process( _delta: float ) -> void:
	if debug and Input.is_action_just_pressed("btn_mouse"):
		var uname = "test_user_%d" % [user_counter]
		user_counter += 1
		_incoming_message( uname, "test message" )
	if debug and Input.is_action_just_pressed( "btn_fire" ):
		if get_child_count() == 0:
			return
		var idx = randi() % get_child_count()
		get_child( idx ).fire()
	_set_formation_positions()


var cur_leader : ProcPlane
func _get_leader() -> ProcPlane:
	if cur_leader and cur_leader.is_leader:
		return cur_leader
	for c in get_children():
		if c.is_leader: return c
	return null


func _generate_latice( nplanes : int ) -> Array:
	var lattice := []
#	var last_pos : Vector2
	var layer = 0
	var position_in_layer = 0
	var vscale : float = 1.0
	if nplanes > 150:
		vscale = 0.25
	elif nplanes > 100:
		vscale = 0.5
	elif nplanes > 70:
		vscale = 0.75
	else:
		vscale = 1.0
	for _n in range( nplanes ):
		if layer == 0:
			lattice.append( Vector2.ZERO )
			layer += 1
			continue
		var max_positions_in_layer = layer + 1
		if max_positions_in_layer > 6:
			max_positions_in_layer = 7 if ( layer % 2 ) == 0 else 6
		var plane_position = Vector2( -( max_positions_in_layer - 1 ) * 0.5 + position_in_layer, layer * vscale)
		if position_in_layer % 2 == 0:
			plane_position.y += 0.2 * vscale
		lattice.append( plane_position )
		position_in_layer += 1
		if position_in_layer >= max_positions_in_layer:
			layer += 1
			position_in_layer = 0
	return lattice


func _incoming_message( username : String, _msg : String ) -> void:
	var plane_idx = _find_plane( username )
	var plane : ProcPlane
	if plane_idx == -1:
		if debug: print( "Creating new user ", username )
		# create new plane
		plane = preload( "res://plane/plane.tscn" ).instance()
		plane.username = username
		plane.msg_score = 1.0
		plane.username = username
		plane.position = _get_plane_starting_position()
		add_child( plane )
	else:
		plane = get_child( plane_idx )
	plane.msg_score += 1
	_update_formation()

func _plane_fire( username : String ) -> void:
	var plane_idx = _find_plane( username )
	if plane_idx == -1:
		return
	get_child( plane_idx ).fire()


func _update_formation() -> void:
	_set_formation_leader()
	match Params.formation_behavior:
		Params.FormationBehaviors.RANDOM:
			formation = []
			for _idx in range( get_child_count() ): formation.append( Vector2.ZERO )
		Params.FormationBehaviors.TRIANGLE:
			formation = _generate_latice( get_child_count() )


func _set_formation_leader() -> void:
	# set leader as highest message score
	var leader : ProcPlane
	var leader_score := -INF
	for idx in range( get_child_count() ):
		var c = get_child( idx ) as ProcPlane
		if c.msg_score > leader_score:
			leader = c
			leader_score = c.msg_score
	var previous_leader = _get_leader()
	if previous_leader == leader:
		for c in get_children():
			if c == leader: continue
			c.is_leader = false
	else:
		for c in get_children():
			if c == leader:
				c.set_as_leader()
			else:
				c.is_leader = false

var last_formation_behavior := -1
func _set_formation_positions() -> void:
	var plane_counter := 1
	var leader = _get_leader()
	if Params.formation_behavior != last_formation_behavior:
		last_formation_behavior = Params.formation_behavior
		_update_formation()
		
	match Params.formation_behavior:
		Params.FormationBehaviors.RANDOM:
			pass
		_:
			if leader:
				for c in get_children():
					if c.is_leader:
						continue
					c.target_position = leader.position + formation[plane_counter] * Params.formation_spacing
					plane_counter += 1


func _find_plane( username : String ) -> int:
	for idx in get_child_count():
		if get_child(idx).username == username:
			return idx
	return -1


func _get_plane_starting_position() -> Vector2:
	var vrect = get_viewport_rect()
	return Vector2( vrect.size.x * 0.5, vrect.size.y + 32 )

