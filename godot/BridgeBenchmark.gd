extends SceneTree

const BRIDGE := "http://127.0.0.1:8090"
var request: HTTPRequest

func _initialize() -> void:
	request = HTTPRequest.new()
	request.timeout = 45.0
	root.add_child(request)
	call_deferred("run")

func call_api(path: String, method: HTTPClient.Method, payload := {}) -> Dictionary:
	var headers := PackedStringArray(["Content-Type: application/json"])
	var err := request.request(BRIDGE + path, headers, method, JSON.stringify(payload) if method != HTTPClient.METHOD_GET else "")
	if err != OK: return {"error": "request_start_failed"}
	var completed: Array = await request.request_completed
	var code: int = completed[1]
	var parsed = JSON.parse_string(completed[3].get_string_from_utf8())
	return parsed if code >= 200 and code < 300 and parsed is Dictionary else {"error": "http_%s" % code}

func run() -> void:
	var samples: Array[float] = []
	var fallback_count := 0
	for i in 5:
		await call_api("/session/reset", HTTPClient.METHOD_POST)
		var start := Time.get_ticks_msec()
		var response := await call_api("/action", HTTPClient.METHOD_POST, {"text": "Look around the room."})
		samples.append((Time.get_ticks_msec() - start) / 1000.0)
		if response.get("status") != "resolved": push_error("Godot bridge turn did not resolve")
	var total := 0.0
	for value in samples: total += value
	var sorted := samples.duplicate(); sorted.sort()
	var result := {"godot_version": Engine.get_version_info().string, "samples": samples, "average_seconds": total / samples.size(), "median_seconds": sorted[2], "min_seconds": sorted[0], "max_seconds": sorted[-1], "sample_count": samples.size(), "fallback_count_from_public_response": fallback_count}
	var file := FileAccess.open("res://godot_bridge_benchmark.json", FileAccess.WRITE); file.store_string(JSON.stringify(result, "  ")); file.close()
	print(JSON.stringify(result))
	quit()
