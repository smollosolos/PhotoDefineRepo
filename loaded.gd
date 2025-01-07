extends Node2D

var BOX = preload("res://vocab_box.tscn")
var path =  ProjectSettings.globalize_path("res://fix/main.exe")
var output = []

@onready var copy_array: RichTextLabel = $CopyArray
@onready var copy_all: RichTextLabel = $CopyAll
@onready var remove_tform_d: RichTextLabel = $RemoveTformD
@onready var lostwords: RichTextLabel = $LostWords/words
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer

var fixed_definitions = []
var words_done = 0
var final_definitions = []

func _ready() -> void:
	var file = FileAccess.open("res://arg.txt", FileAccess.WRITE)
	if file:
		for i in range(global.definitions.size()):
			if global.definitions[i] == "f":
				file.store_line(global.titles[i].replace(" ", "_").replace("'", "%27"))
		file.close()
	OS.execute(path,[], output)
	var output_file = FileAccess.open("res://arg.txt", FileAccess.READ)
	fixed_definitions = output_file.get_as_text().split("\n")
	for i in range(fixed_definitions.size()):
		var def : String = fixed_definitions[i]
		final_definitions.append(global.format_def(def))
	load_lost_words()
	load_def()
	
func load_def():
	words_done = 0
	for i in range(global.definitions.size()):
		var box = BOX.instantiate()
		v_box_container.add_child(box)
		var def = global.definitions[i]
		if def == "f":
			def = final_definitions[words_done]
			words_done +=1
		box.input_box(global.titles[i].replace("_", " "),def)
	if v_box_container.get_child_count() > 3:
		var box = BOX.instantiate()
		v_box_container.add_child(box)


func load_lost_words():
	lostwords.text = "\n".join(global.lost_words)
		

func _on_button_1_pressed() -> void:
	words_done = 0
	var copy = ""
	for i in range(global.definitions.size()):
		var def = global.definitions[i]
		if def == "f":
			def = final_definitions[words_done]
			words_done +=1
		copy += global.titles[i] +" - "+def +"\n"
	DisplayServer.clipboard_set(copy)


func _on_button_1_mouse_entered() -> void:
	copy_all.text = "[u]Copy All[/u]"


func _on_button_1_mouse_exited() -> void:
	copy_all.text = "Copy All"


func _on_button_2_pressed() -> void:
	words_done = 0
	var copy = []
	for i in range(global.definitions.size()):
		var def = global.definitions[i]
		if def == "f":
			def = final_definitions[words_done]
			words_done +=1
		copy.append(def)
	DisplayServer.clipboard_set("["+ str(copy) +"," + str(global.titles)+"]")


func _on_button_2_mouse_entered() -> void:
	copy_array.text = "[u]Copy to Array[/u]"



func _on_button_2_mouse_exited() -> void:
	copy_array.text = "Copy to Array"


func _on_button_3_pressed() -> void:
	words_done = 0
	for i in range(global.titles.size()):
		global.titles[i] = global.titles[i].replace("'","’")
		var words
		if " " in global.titles[i]:
			words = global.titles[i].split(" ")
			
			if global.definitions[i] == "f":
				for word in words:
					final_definitions[words_done] = final_definitions[words_done].replacen(word, "____")
				words_done +=1
			else:
				for word in words:
					global.definitions[i] = global.definitions[i].replacen(word, "____")
		else:
			if global.definitions[i] == "f":
				final_definitions[words_done] = final_definitions[words_done].replacen(global.titles[i], "____")
				words_done +=1
			else:
				global.definitions[i] = global.definitions[i].replacen(global.titles[i], "____")
	for child in v_box_container.get_children():
		child.queue_free()
	load_def()
			


func _on_button_3_mouse_entered() -> void:
	remove_tform_d.text = "[u]Remove Titles from Definitions[/u]"


func _on_button_3_mouse_exited() -> void:
	remove_tform_d.text = "Remove Titles"
