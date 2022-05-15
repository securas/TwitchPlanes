extends Node2D

signal enemy_dead

enum EnemyStates { MOVE, HIT }

var state : int = EnemyStates.MOVE
var vel : float = Params.enemy_vel
var hit_timer := 5.0


	

func _physics_process(delta: float) -> void:
	match state:
		EnemyStates.MOVE:
			position += Vector2.RIGHT * vel * delta
			if position.x > get_viewport_rect().size.x + 32:
				emit_signal( "enemy_dead" )
				queue_free()
		EnemyStates.HIT:
			hit_timer -= delta
			if hit_timer <= 0:
				emit_signal( "enemy_dead" )
				queue_free()

func _on_receiving_damage( _from, _val ):
	$hit_anim.play("hit")
	state = EnemyStates.HIT
	$RcvDamageArea/CollisionShape2D.call_deferred( "set_disabled", true )
	
