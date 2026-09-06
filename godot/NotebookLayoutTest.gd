extends SceneTree

func _initialize() -> void:
	var ui = load("res://Main.gd").new()
	ui.build_ui()
	for count in [1, 4, 10]:
		var clues := {}
		for index in count:
			clues["clue_%d" % index] = {"display_name": "Clue %d" % index, "known_facts": ["A readable fact with enough length to exercise wrapping in the notebook column."], "player_note": null}
		var theories := {"one": {"title": "First theory", "body": "A sufficiently long theory body to wrap without overlapping its neighbors.", "linked_clue_ids": []}, "two": {"title": "Second theory", "body": "Another theory remains visually separate.", "linked_clue_ids": []}}
		var book := {"Clues": clues, "Characters": {}, "Locations": {}, "Theories": theories}
		ui.update_notebook(book)
		var parsed: String = ui.clue_text.get_parsed_text()
		if parsed.count("Clue ") != count or not ui.clue_text.scroll_active:
			push_error("Notebook clue layout failed at %d entries" % count); quit(1); return
		ui.update_notebook(book)
		if ui.clue_text.get_parsed_text().count("Clue ") != count:
			push_error("Notebook rebuild duplicated clue text"); quit(1); return
	if ui.theory_list.get_parsed_text().count("theory") < 2 or not ui.theory_list.scroll_active:
		push_error("Notebook theory layout failed"); quit(1); return
	print("Notebook layout tests passed: 1, 4, 10 clues, long wrapping text, repeated rebuild, and multiple theories.")
	ui.free()
	quit(0)
