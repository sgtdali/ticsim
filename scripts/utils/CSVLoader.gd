extends RefCounted
class_name CSVLoader

# Loads a CSV file from res:// and maps it to Array[Dictionary]
static func load_csv(file_path: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	
	if not FileAccess.file_exists(file_path):
		push_error("CSVLoader: File not found: " + file_path)
		return results
		
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("CSVLoader: Failed to open file: " + file_path + " (Error code: " + str(FileAccess.get_open_error()) + ")")
		return results
		
	var headers: PackedStringArray = file.get_csv_line()
	if headers.size() == 0 or headers[0] == "":
		file.close()
		return results
		
	# Handle UTF-8 BOM
	if headers[0].begins_with("\uFEFF"):
		headers[0] = headers[0].substr(1)
		
	# Strip any trailing whitespace from headers
	for i in range(headers.size()):
		headers[i] = headers[i].strip_edges()
		
	while not file.eof_reached():
		var line := file.get_csv_line()
		
		# Skip empty lines
		if line.size() == 0 or (line.size() == 1 and line[0] == ""):
			continue
			
		var row: Dictionary = {}
		for i in range(headers.size()):
			var val := ""
			if i < line.size():
				val = line[i].strip_edges()
			row[headers[i]] = val
		results.append(row)
		
	file.close()
	return results

# Helper to safely parse floats from string value
static func parse_float(val: String, default: float = 0.0) -> float:
	val = val.strip_edges()
	if val == "" or not val.is_valid_float():
		return default
	return val.to_float()

# Helper to safely parse integers from string value
static func parse_int(val: String, default: int = 0) -> int:
	val = val.strip_edges()
	if val == "" or not val.is_valid_int():
		return default
	return val.to_int()
