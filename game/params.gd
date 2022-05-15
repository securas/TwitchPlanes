extends Node


enum FormationBehaviors { RANDOM, TRIANGLE }
enum LeaderBehavior { RANDOM }
enum ScreenOrientations { PORTRAIT, LANDSCAPE }

var max_message_time := 1000.0
var plane_max_vel := 30.0
var formation_spacing := Vector2( 40, 32 )
var deviation_from_formation := 0.15

var screen_stretch := 1.5
var screen_size := Vector2( 1024, 600 )
var screen_orientation : int = ScreenOrientations.LANDSCAPE


var formation_behavior : int = FormationBehaviors.RANDOM
var leader_behavior : int  = LeaderBehavior.RANDOM

var trail_color := Color( "d1b1b1b5" )
var characters_in_username := 4
var bullet_vel := 120.0

var enemy_vel := 20.0
var max_enemies := 5
