extends Node2D

var path =  ProjectSettings.globalize_path("res://python/main.exe")
var words : String

var output = []

var final_words : PackedStringArray = []
var definitions : PackedStringArray = []
var titles : PackedStringArray = []

var titlerequests : HTTPRequest = HTTPRequest.new()
var defrequests : HTTPRequest = HTTPRequest.new()

var json = JSON.new()

var words_done : int = 0
var temp_title : String
var new_title : String

@onready var definetext: Label = $WordFix/definetext
@onready var define: TextureButton = $WordFix/define
@onready var error: Label = $GetImage/error
@onready var word_fix: Node2D = $WordFix
@onready var get_image: Node2D = $GetImage
@onready var text_edit: TextEdit = $WordFix/TextEdit
@onready var go_type: RichTextLabel = $GetImage/goType
@onready var go_type_button: TextureButton = $GetImage/goTypeButton
@onready var loading: Sprite2D = $WordFix/Loading
@onready var load_anim: AnimationPlayer = $WordFix/Loading/AnimationPlayer
@onready var upload = $GetImage/upload


func _ready() -> void:
	var file = FileAccess.open("res://arg.txt", FileAccess.WRITE)
	if file:
		file.store_line("")
		file.close()
	add_child(titlerequests)
	add_child(defrequests)
	titlerequests.request_completed.connect(self.on_title_request_completed)
	defrequests.request_completed.connect(self.on_def_request_completed)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("paste"):
		error.visible = false
		format_input()

func format_input() -> void:
	OS.execute(path, [], output)
	words = output[0]
	if not "NAN" in words:
		words = words.replace("\r", "")
		var a = words.split("\n")

		while "" in a:
			a.remove_at(a.find(""))
		words = "\n".join(a)
		
		for c in words:
			var ascii : int = c.to_upper().unicode_at(0)
			if not ((ascii >= 65 and ascii <= 90) or c == " " or c == "\n"):
				words = words.replace(c,"")
		
		words = words.replace(" ","\n")
		
		text_edit.text = words
		get_image.visible = false
		word_fix.visible = true
		
	else:
		write_error("Wasn't able to decode image. Please try again or type the words in.")


func _on_upload_pressed() -> void:
	var results = []
	OS.execute("powershell.exe", PackedStringArray(["\"Add-Type -AssemblyName System.Windows.Forms; $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog; [void]$FileBrowser.ShowDialog(); $FileBrowser.FileName\""]), results)
	var file = FileAccess.open("res://arg.txt", FileAccess.WRITE)
	if file:
		file.store_line(results[0])
		file.close()
	else:
		write_error("Failed to open file")
	format_input()
		

func write_error(err : String):
	error.text = err
	error.visible = true


func _on_go_type_button_mouse_entered() -> void:
	go_type.text = "[u]No image? Click here to type[/u]"
	


func _on_go_type_button_mouse_exited() -> void:
	go_type.text = "No image? Click here to type"


func _on_go_type_button_pressed() -> void:
	get_image.visible = false
	word_fix.visible = true


func _on_define_pressed() -> void:
	final_words = text_edit.text.split("\n")
	get_titles()
	define.disabled = true
	definetext.visible = false
	define.visible = false
	loading.visible = true
	load_anim.play("loading")


func on_title_request_completed(result, response_code, headers, body):
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if response.size() > 1:
		if response[1].size() > 0:
			var title : String  = response[1][0].replace(" ", "_").replace("'", "%27")
			titles.append(title)
		else:
			global.lost_words.append(temp_title)
	else:
		global.lost_words.append(temp_title)
	
func get_titles():
	for i in range(final_words.size()):
		temp_title = final_words[i]
		titlerequests.request("https://en.wikipedia.org/w/api.php?action=opensearch&origin=*&format=json&search="+final_words[i].replace(" ", ""))
		await titlerequests.request_completed
	global.titles = titles
	titlerequests.queue_free()
	get_definitions()

func on_def_request_completed(result, response_code, headers, body):
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var id : String = response["query"]["pages"].keys()[0]
	var info : String = response["query"]["pages"][id]["revisions"][0]["*"]
	if "#REDIRECT" in info:
		var start = info.find("[[") + 2
		titles[words_done] = info.substr(start, info.find("]") - start)
		definitions.append("f")
	else:
		var start : int = info.find("'''")
		info = info.substr(start)
		info = info.substr(0, info.find("\n"))
		definitions.append(global.format_def(info))

		
func get_definitions():
	for i in range(titles.size()):
		words_done = i
		defrequests.request("https://en.wikipedia.org/w/api.php?action=query&origin=*&prop=revisions&rvprop=content&format=json&titles="+titles[i])
		await defrequests.request_completed
	defrequests.queue_free()
	global.definitions = definitions
	get_tree().change_scene_to_file("res://loaded.tscn")

	


func _on_upload_mouse_entered() -> void:
	var tween = create_tween()
	tween = tween.tween_property(upload, "modulate", Color(0.7,0.7,0.7,1), 0.01)


func _on_upload_mouse_exited() -> void:
	var tween = create_tween()
	tween = tween.tween_property(upload, "modulate", Color(1,1,1,1), 0.01)


func _on_define_mouse_entered() -> void:
	var tween = create_tween()
	tween = tween.tween_property(define, "modulate", Color(0.7,0.7,0.7,1), 0.01)


func _on_define_mouse_exited() -> void:
	var tween = create_tween()
	tween = tween.tween_property(define, "modulate", Color(1,1,1,1), 0.01)
