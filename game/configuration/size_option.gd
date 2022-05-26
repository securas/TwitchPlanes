tool
extends Control

signal value_changed( newvalue )

export( String ) var text := "title" setget _set_text
export( Array, int ) var possible_values := [ 100 ]
export( int ) var initial_value_idx := 0
var value_idx := 0


func _set_text( v : String ) -> void:
	text = v
	$title.text = v


func _ready() -> void:
	if Engine.editor_hint: return
	_set_text( text )
	value_idx = initial_value_idx
	_update_value()

func _update_value():
	$value.text = "%d" % [ possible_values[value_idx] ]

func _on_up_pressed() -> void:
	value_idx = int( min( value_idx + 1, possible_values.size() - 1 ) )
	_update_value()
	if Engine.editor_hint: return
	emit_signal( "value_changed", possible_values[value_idx] )




func _on_down_pressed() -> void:
	value_idx = int( max( value_idx - 1, 0 ) )
	_update_value()
	if Engine.editor_hint: return
	emit_signal( "value_changed", possible_values[value_idx] )
	
