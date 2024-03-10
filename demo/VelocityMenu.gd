class_name VelocityMenu
extends MenuButton

signal switch_velocity(velocity:int)

var values := [3,5,7]
var labels := ["Piano", "Mezzo", "Forte"]

@onready var popUp := get_popup()

func _ready() -> void:
	popUp.connect("id_pressed", onClick)


func onClick(id: int):
	var idx := popUp.get_item_index(id)
	for i in range(0, popUp.item_count):
		popUp.set_item_checked(i, idx == i)
	text = "Velocity: " + popUp.get_item_text(idx)

	emit_signal("switch_velocity", values[idx])

