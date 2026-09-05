extends Control

const BRIDGE := "http://127.0.0.1:8090"
var request: HTTPRequest
var history: RichTextLabel
var location_label: Label
var time_label: Label
var status_label: Label
var input: LineEdit
var submit: Button
var notebook_tabs: TabContainer
var clue_text: RichTextLabel
var character_box: VBoxContainer
var location_text: RichTextLabel
var theory_list: RichTextLabel
var theory_title: LineEdit
var theory_body: TextEdit
var clue_picker: OptionButton
var theory_picker: OptionButton
var end_panel: PanelContainer
var end_label: Label
var latest_turn_id := ""
var pending_kind := ""

func _ready() -> void:
	build_ui()
	request = HTTPRequest.new()
	request.timeout = 45.0
	add_child(request)
	request.request_completed.connect(_on_request_completed)
	call_api("/session/state", HTTPClient.METHOD_GET, {}, "state")

func build_ui() -> void:
	var bg := ColorRect.new(); bg.color = Color("101014"); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var root := VBoxContainer.new(); root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16); root.add_theme_constant_override("separation", 10); add_child(root)
	var header := HBoxContainer.new(); root.add_child(header)
	location_label = Label.new(); location_label.text = "CALLUM'S STUDY"; location_label.add_theme_font_size_override("font_size", 25); location_label.add_theme_color_override("font_color", Color("d1ad68")); header.add_child(location_label)
	var spacer := Control.new(); spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL; header.add_child(spacer)
	time_label = Label.new(); time_label.text = "8:00 PM"; time_label.add_theme_color_override("font_color", Color("d8ccb2")); header.add_child(time_label)
	var body := HSplitContainer.new(); body.size_flags_vertical = Control.SIZE_EXPAND_FILL; body.split_offset = 820; root.add_child(body)
	history = RichTextLabel.new(); history.bbcode_enabled = true; history.fit_content = false; history.scroll_active = true; history.add_theme_color_override("default_color", Color("e9dfca")); history.add_theme_font_size_override("normal_font_size", 18); history.text = "[color=#d1ad68][b]Callum's Study[/b][/color]\nRain traces the window. The room has been disturbed, and Guillermo watches from the desk.\n\n"; body.add_child(history)
	notebook_tabs = TabContainer.new(); notebook_tabs.custom_minimum_size.x = 390; body.add_child(notebook_tabs)
	clue_text = make_rich_tab("Clues"); character_box = VBoxContainer.new(); character_box.name = "Characters"; notebook_tabs.add_child(character_box); location_text = make_rich_tab("Locations")
	var theory_panel := VBoxContainer.new(); theory_panel.name = "Theories"; notebook_tabs.add_child(theory_panel)
	theory_list = RichTextLabel.new(); theory_list.bbcode_enabled = true; theory_list.custom_minimum_size.y = 170; theory_list.size_flags_vertical = Control.SIZE_EXPAND_FILL; theory_panel.add_child(theory_list)
	theory_title = LineEdit.new(); theory_title.placeholder_text = "Theory title"; theory_panel.add_child(theory_title)
	theory_body = TextEdit.new(); theory_body.placeholder_text = "What do you think it means?"; theory_body.custom_minimum_size.y = 80; theory_panel.add_child(theory_body)
	var save_theory := Button.new(); save_theory.text = "Save theory (belief)"; save_theory.pressed.connect(_save_theory); theory_panel.add_child(save_theory)
	theory_picker = OptionButton.new(); clue_picker = OptionButton.new(); theory_panel.add_child(theory_picker); theory_panel.add_child(clue_picker)
	var link := Button.new(); link.text = "Link selected clue"; link.pressed.connect(_link_clue); theory_panel.add_child(link)
	var controls := HBoxContainer.new(); root.add_child(controls)
	input = LineEdit.new(); input.placeholder_text = "Type what Armand does..."; input.size_flags_horizontal = Control.SIZE_EXPAND_FILL; input.text_submitted.connect(func(_t): submit_action()); controls.add_child(input)
	submit = Button.new(); submit.text = "Act"; submit.pressed.connect(submit_action); controls.add_child(submit)
	var restart := Button.new(); restart.text = "Restart"; restart.pressed.connect(func(): call_api("/session/reset", HTTPClient.METHOD_POST, {}, "reset")); controls.add_child(restart)
	status_label = Label.new(); status_label.text = "Guillermo: nearby • Early gestures"; status_label.add_theme_color_override("font_color", Color("b89a67")); root.add_child(status_label)
	end_panel = PanelContainer.new(); end_panel.visible = false; end_panel.position = Vector2(390, 260); end_panel.size = Vector2(500, 170); add_child(end_panel)
	var end_box := VBoxContainer.new(); end_panel.add_child(end_box); end_label = Label.new(); end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; end_label.add_theme_font_size_override("font_size", 24); end_box.add_child(end_label)
	var continue_button := Button.new(); continue_button.text = "Continue exploring"; continue_button.pressed.connect(func(): end_panel.visible = false); end_box.add_child(continue_button)
	var restart_end := Button.new(); restart_end.text = "Restart slice"; restart_end.pressed.connect(func(): end_panel.visible = false; call_api("/session/reset", HTTPClient.METHOD_POST, {}, "reset")); end_box.add_child(restart_end)

func make_rich_tab(title: String) -> RichTextLabel:
	var rich := RichTextLabel.new(); rich.name = title; rich.bbcode_enabled = true; notebook_tabs.add_child(rich); return rich

func submit_action() -> void:
	var text := input.text.strip_edges()
	if text.is_empty() or request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: return
	input.clear(); set_busy(true); call_api("/action", HTTPClient.METHOD_POST, {"text": text}, "action")

func call_api(path: String, method: HTTPClient.Method, payload: Dictionary, kind: String) -> void:
	pending_kind = kind
	var headers := PackedStringArray(["Content-Type: application/json"])
	var error := request.request(BRIDGE + path, headers, method, JSON.stringify(payload) if method != HTTPClient.METHOD_GET else "")
	if error != OK: history.append_text("\n[color=salmon]Bridge request could not start.[/color]\n"); set_busy(false)

func _on_request_completed(_result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray) -> void:
	set_busy(false)
	var parsed = JSON.parse_string(bytes.get_string_from_utf8())
	if code < 200 or code >= 300 or not parsed is Dictionary:
		history.append_text("\n[color=salmon]The local game bridge returned an error.[/color]\n"); return
	if pending_kind == "action":
		latest_turn_id = str(parsed.get("turn_id", "")); history.append_text("\n[color=#d1ad68]>[/color] " + str(parsed.get("narration", "")) + "\n"); history.scroll_to_line(history.get_line_count())
		update_state(parsed.get("state", {}))
	elif pending_kind == "theory" or pending_kind == "link": call_api("/notebook", HTTPClient.METHOD_GET, {}, "notebook")
	elif pending_kind == "notebook": update_notebook(parsed)
	else: update_state(parsed)

func set_busy(busy: bool) -> void:
	input.editable = not busy; submit.disabled = busy; status_label.text = "Thinking…" if busy else "Guillermo: nearby • Early gestures"

func update_state(state: Dictionary) -> void:
	var loc: Dictionary = state.get("location", {}); location_label.text = str(loc.get("name", "Unknown")).to_upper(); time_label.text = str(state.get("time", "")); update_notebook(state.get("notebook", {}))
	var slice: Dictionary = state.get("slice_state", {}); if slice.get("ending_reached", false): end_label.text = str(slice.get("ending_title", "LEAD DISCOVERED")) + "\n\n" + str(slice.get("ending_text", "")); end_panel.visible = true

func update_notebook(book: Dictionary) -> void:
	clue_text.clear(); clue_picker.clear(); var clues: Dictionary = book.get("Clues", {})
	for id in clues:
		var clue: Dictionary = clues[id]; clue_text.append_text("[b]" + str(clue.get("display_name", id)) + "[/b]\n"); clue_picker.add_item(str(clue.get("display_name", id))); clue_picker.set_item_metadata(clue_picker.item_count - 1, id)
		for fact in clue.get("known_facts", []): clue_text.append_text("• " + str(fact) + "\n")
		if clue.get("player_note") != null: clue_text.append_text("[i]Your note: " + str(clue.player_note) + "[/i]\n")
		clue_text.append_text("\n")
	for child in character_box.get_children(): child.queue_free()
	var characters: Dictionary = book.get("Characters", {})
	for id in characters:
		var character: Dictionary = characters[id]; var row := CheckBox.new(); row.text = "★ " + str(character.get("display_name", id)); row.button_pressed = bool(character.get("important", false)); row.toggled.connect(func(on: bool): call_api("/notebook/character/important", HTTPClient.METHOD_POST, {"character_id": id, "important": on}, "notebook")); character_box.add_child(row)
	location_text.clear(); var locations: Dictionary = book.get("Locations", {}); for id in locations: var loc: Dictionary = locations[id]; location_text.append_text("[b]" + str(loc.get("display_name", id)) + "[/b]\n"); for feature in loc.get("known_features", []): location_text.append_text("• " + str(feature) + "\n"); location_text.append_text("\n")
	theory_list.clear(); theory_picker.clear(); var theories: Dictionary = book.get("Theories", {}); for id in theories: var theory: Dictionary = theories[id]; theory_list.append_text("[b]" + str(theory.get("title", id)) + "[/b] [i](belief)[/i]\n" + str(theory.get("body", "")) + "\nLinked clues: " + ", ".join(theory.get("linked_clue_ids", [])) + "\n\n"); theory_picker.add_item(str(theory.get("title", id))); theory_picker.set_item_metadata(theory_picker.item_count - 1, id)

func _save_theory() -> void:
	if theory_title.text.strip_edges().is_empty() or theory_body.text.strip_edges().is_empty(): return
	call_api("/notebook/theory", HTTPClient.METHOD_POST, {"title": theory_title.text, "body": theory_body.text}, "theory"); theory_title.clear(); theory_body.clear()

func _link_clue() -> void:
	if theory_picker.item_count == 0 or clue_picker.item_count == 0: return
	call_api("/notebook/theory/link", HTTPClient.METHOD_POST, {"theory_id": theory_picker.get_selected_metadata(), "entity_type": "clue", "entity_id": clue_picker.get_selected_metadata()}, "link")
