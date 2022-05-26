extends Control

signal update_configuration


func _on_window_height_value_changed( ysize : int ) -> void:
	Params.screen_size.y = ysize
	emit_signal( "update_configuration" )


func _on_window_width_value_changed( xsize : int) -> void:
	Params.screen_size.x = xsize
	emit_signal( "update_configuration" )


func _on_zoom_level_value_changed( zoom_level : int ) -> void:
	Params.screen_stretch = 0.6 + 0.1 * zoom_level
	emit_signal( "update_configuration" )


func _on_background_transparency_value_changed( background_state : int ) -> void:
	Params.background_state = background_state - 1
	emit_signal( "update_configuration" )
