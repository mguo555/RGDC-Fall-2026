extends LineEdit


var _regex := RegEx.new()

func _ready() -> void:
	_regex.compile("[^0-9]")   # matches anything that is NOT a digit

func _on_text_changed(new_text: String) -> void:
	var cleaned := _regex.sub(new_text, "", true)   # remove all non-digits
	if cleaned != new_text:
		var caret := caret_column
		text = cleaned
		caret_column = min(caret - 1, cleaned.length())
