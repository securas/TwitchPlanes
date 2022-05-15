extends Node2D

var timer : Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.autostart = false
	add_child( timer )
#	timer.start()
	var _ret = timer.connect( "timeout", self, "_on_timeout" )




func _on_timeout():
	if get_child_count() > Params.max_enemies:
		timer.wait_time = 1.0
		timer.start()
		return
	
	var e = preload( "res://enemy/enemy.tscn" ).instance()
	e.position = Vector2( -40, 32 + ( ( randi() % 3 ) - 1 ) * 8 )
	add_child( e )
	
	timer.wait_time = 2.0 + randf() * 3.0
	timer.start()
