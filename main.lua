require("src/string_util")
is_windows = require("src/is_windows")

local merger = require("src/merger")

merger:merge_def_files()
merger:merge_enum_files()
merger:merge_actors()

local file, err = io.open("types.luau", "w")
file:write(merger.output)
file:close()