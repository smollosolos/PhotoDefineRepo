extends Control
@onready var Title: Label = $Title
@onready var Def: TextEdit = $Def
@onready var button = $TextureButton


func input_box(title : String, def : String):
	Title.text = title
	Def.text = def
	
func _on_texture_button_pressed() -> void:
	DisplayServer.clipboard_set(Title.text +" - "+Def.text)


func _on_texture_button_mouse_entered() -> void:
	var tween = create_tween()
	tween = tween.tween_property(button, "modulate", Color(0.7,0.7,0.7,1), 0.01)


func _on_texture_button_mouse_exited() -> void:
	var tween = create_tween()
	tween = tween.tween_property(button, "modulate", Color(1,1,1,1), 0.01)
