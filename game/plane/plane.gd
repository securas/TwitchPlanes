extends Node2D
class_name ProcPlane

enum PlaneStates { START, WANDER, LEAVING, HIT, AWAY, FIRE, HOLDOFF }
enum LeaderBehaviors { RANDOM_POSITION }

const MAX_ANGLE = 1.0


const COLORS = [
	Color( "c73041" ),
	Color( "a2674b" ),
	Color( "2bb65f" ),
	Color( "81685c" ),
	Color( "515565" ),
	Color( "fc683b" ),
	Color( "239ec5" ),
]

export( Texture ) var plane_texture
export( String ) var username : String

onready var rotate = $rotate
var msg_score := 0.0
var max_vel : float
var state : int = PlaneStates.START
var vel : Vector2
var is_leader := false
var target_position : Vector2
var leader_behavior : int = LeaderBehaviors.RANDOM_POSITION
var start_timer := 2.0
var target_position_timer := 0.0
var target_position_offset : Vector2

func _ready() -> void:
	max_vel = Params.plane_max_vel + randf() * 10 - 5
	if plane_texture:
		$rotate/plane_sprite.texture = plane_texture
	if username:
		$name_node/name.modulate = COLORS[ randi() % COLORS.size() ]
		var text_name : String
		if username.length() > Params.characters_in_username:
			text_name = "%s..." % [username.substr( 0, Params.characters_in_username ) ]
		else:
			text_name = username + ""
		$name_node/name.text = text_name
	
	$rotate/plane_sprite.texture = Planes.get_random_texture()




func _physics_process(delta: float) -> void:
	$rotate/trailpos/trail.default_color = Params.trail_color
	match Params.formation_behavior:
		Params.FormationBehaviors.RANDOM:
			target_position = _behavior_random_position( delta )
		
		Params.FormationBehaviors.TRIANGLE:
			if is_leader:
				match leader_behavior:
					LeaderBehaviors.RANDOM_POSITION:
						target_position = _behavior_random_position( delta )
				target_position_offset *= 0
			else:
				target_position_timer -= delta
				if  target_position_timer <= 0:
					target_position_timer = 2.0
					target_position_offset = Params.deviation_from_formation * Vector2( rand_range( -1, 1 ), rand_range( -1, 1 ) )
					target_position_offset *= Params.formation_spacing
	
	if state == PlaneStates.HIT:
		if not $rotate/plane_particles.emitting:
			$rotate/plane_particles.emitting = true
	else:
		$rotate/plane_particles.emitting = false
	
	match state:
		PlaneStates.START:
			# move to target position quickly
			var dist = target_position - position
			var distlen = dist.length()
			var desired_vel = dist.normalized() * max_vel * 2 # double the max speed
			var force = -vel + desired_vel
			vel += force * delta
			vel = vel.clamped( max_vel * 2 )
			position += vel * delta
			start_timer -= delta
			if distlen < 8:
				start_timer -= delta
				if start_timer <= 0:
					state = PlaneStates.WANDER
			else:
				start_timer = 2.0
		
		PlaneStates.WANDER:
			_update_msg_score( delta )
			var position_rect = get_viewport_rect().grow(-32)
			position_rect.position.y += 16
			var dist = ( target_position + target_position_offset ) - position
			var desired_vel = dist.normalized() * max_vel
			var distlen = dist.length()
			desired_vel *= 1 if distlen > 8 else distlen / 8.0
			var force = -vel + desired_vel
			var screenpos = get_global_transform_with_canvas().origin
			if not position_rect.has_point( screenpos ):
				var position_force = ( position_rect.position + position_rect.size * 0.5 ) - screenpos
				force += position_force
			force += _get_avoid_force()
			vel += force * delta
			vel = vel.clamped( max_vel * 2 )
			position += vel * delta
		
		PlaneStates.LEAVING:
			target_position = get_viewport_rect().size * Vector2( 0.5, 1.0 ) + Vector2( 0, 60 )
			var dist = target_position - position
			var distlen = dist.length()
			var desired_vel = dist.normalized() * max_vel * 1.5
			var force = -vel + desired_vel
			vel += force * delta
			vel = vel.clamped( max_vel * 2 )
			position += vel * delta
			if distlen < 3:
				_terminate()
		
		PlaneStates.HIT:
			target_position = get_viewport_rect().size * Vector2( 0.5, 1.0 ) + Vector2( 0, 60 )
			var dist = target_position - position
			var distlen = dist.length()
			var desired_vel = dist.normalized() * max_vel * 1.5
			var force = -vel + desired_vel
			vel += force * delta
			vel = vel.clamped( max_vel * 2 )
			position += vel * delta
			if distlen < 3:
				_terminate()
		
		
		PlaneStates.FIRE:
			vel = lerp( vel, Vector2.ZERO, 2 * delta )
			position += vel * delta
			fire_timer -= delta
			if fire_timer <= 0:
				var b = preload ("res://plane/plane_bullet.tscn" ).instance()
				b.position = position + Vector2.UP * 20
				var _ret = b.connect ("bullet_hit", self, "_on_bullet_hit" )
				get_parent().get_parent().add_child( b )
				var x = preload( "res://plane/nozzle_blast.tscn" ).instance()
				x.position = Vector2.UP * 16
				add_child( x )
				
				fire_timer = 2.0
				state = PlaneStates.HOLDOFF
		
		PlaneStates.HOLDOFF:
			vel = lerp( vel, Vector2.ZERO, 2 * delta )
			position += vel * delta
			fire_timer -= delta
			if fire_timer <= 0:
				state = PlaneStates.WANDER
	
	var rot_angle = clamp( vel.x, -Params.plane_max_vel * 0.3, Params.plane_max_vel * 0.3 ) / ( Params.plane_max_vel * 0.3 )
#	print( vel.x, " ", rot_angle )
	rotate.rotation = rot_angle * 0.25

func set_as_leader():
	is_leader = true
	state = PlaneStates.START

var random_behavior_timer := 0.0
func _behavior_random_position( delta ) -> Vector2:
	random_behavior_timer -= delta
	if random_behavior_timer <= 0:
		random_behavior_timer = 2.0 + randf() * 6.0
	else:
		return target_position # without changes
	var vrect = get_viewport_rect()
	if is_leader:
		var new_position = Vector2(
			rand_range( vrect.size.x * 0.1, vrect.size.x * 0.9 ),
			rand_range( 48, vrect.size.y * 0.8 )
		)
#		print( "new leader position: ", new_position )
		return new_position
	else:
		var new_position = Vector2(
			rand_range( vrect.size.x * 0.1, vrect.size.x * 0.9 ),
			rand_range( 48, vrect.size.y * 0.9 )
		)
#		print( "new position: ", new_position )
		return new_position



func _terminate():
	queue_free()

func set_msg( _msg : String ):
	# currently do nothing with message
	pass

func _get_avoid_force() -> Vector2:
	if Params.formation_behavior != Params.FormationBehaviors.RANDOM: return Vector2.ZERO
	var others = $avoid_area.get_overlapping_areas()
	if not others: return Vector2.ZERO
	var force = Vector2.ZERO
	for o in others:
		force += global_position - o.global_position
	return force

func _update_msg_score( delta : float ) -> void:
	if msg_score > 0:
		msg_score -= delta / Params.max_message_time
		if msg_score <= 0:
			msg_score = 0.0
			state = PlaneStates.LEAVING



var last_state : int
var fire_timer : float
func fire():
	if state == PlaneStates.FIRE or state == PlaneStates.HOLDOFF or state == PlaneStates.HIT:
		return
	last_state = state
	state = PlaneStates.FIRE
	fire_timer = 1.0
	
func _on_receiving_damage( _from, _val ):
	$rotate/plane_particles.emitting = true
	state = PlaneStates.HIT

func _on_bullet_hit( target : Node ):
	var score : int
	if target is get_script():
		score = 1
	else:
		score = 2
	msg_score += score
