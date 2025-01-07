extends Node

var lost_words = []
var titles = []
var definitions = []

func format_def(def):
	var file = FileAccess.open("res://temp.txt", FileAccess.WRITE)
	if file:
		file.store_line(def)
		file.close()
	var path =  ProjectSettings.globalize_path("res://format/main.exe")
	var output = []
	OS.execute(path, [], output)
	return output[0]
