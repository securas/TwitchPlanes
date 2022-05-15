extends Node2D

signal bullet_hit

var type := 0


func _ready():
	if type == 0:
		$bullet.region_rect.position.x = 144
	else:
		$bullet.region_rect.position.x = 144 + 16

func _physics_process( delta: float ) -> void:
	position += Vector2.UP * Params.bullet_vel * delta
	if position.y <= -50:
		queue_free()

func _on_dealing_damage( to ):
	var x = preload( "res://plane/explosion.tscn" ).instance()
	x.position = position + Vector2.UP * 8
	get_parent().add_child( x )
	emit_signal( "bullet_hit", to )
	queue_free()
	
