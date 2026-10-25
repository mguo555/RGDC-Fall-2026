extends NavigationRegion2D

# works out where guards and npcs can walk when the level starts.
# anything with a collision shape under this node (like the tilemap)
# becomes something they walk around, so nobody has to re-bake it by hand
func _ready() -> void:
	bake_navigation_polygon(false)
