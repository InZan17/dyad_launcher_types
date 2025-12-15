local components = require("src/components")
local actors = require("src/actors")

local merger = {}

merger.output = ""
merger.found_enums = {}

function merger:merge_str(str)
    trimmed_str = str:trim()
    self.output = self.output..str.."\n\n" 
end

function merger:merge_file(filepath)
    local file = io.open(filepath, "r")
    local content = file:read("*all")
    self:merge_str(content)
end

function merger:merge_def_files()
    local file_directory = "./def_files"

    if is_windows then
        for dir in io.popen("dir \""..file_directory.."\" /b"):lines() do
            self:merge_file(file_directory.."/"..dir)
        end
    else
        for dir in io.popen("ls -pa \""..file_directory.."\" | grep -v /"):lines() do
            self:merge_file(file_directory.."/"..dir)
        end
    end
end

function merger:merge_enum_file(file_directory, file_name)
    local enum_name = file_name:gsub("%..*$", "")
    local enum_description = ""

    local filepath = file_directory.."/"..file_name
    local file = io.open(filepath, "r")
    local content = file:read("*all")

    local lines = {}
    for str in string.gmatch(content, "([^\n]+)") do
        if str:startswith("/") then
            str = str:sub(2)
            str = str:trim()
            enum_description = enum_description..str.."\n"
        elseif str ~= "" then
            table.insert(lines, str)
        end
    end

    enum_description = enum_description:trim()

    local enum_def_string = 
        "--- "..enum_description..
        "\ndeclare class "..enum_name.." end"..
        "\n--- "..enum_description..
        "\ndeclare class "..enum_name.."Enums"

    local enum_def_fields_string = ""

    local active_variant = nil
    local active_variant_description = ""

    local function insert_active_enum()
        local variant_name = active_variant
        local variant_value = enum_name

        if active_variant:endswith(")") then
            local last_index = active_variant:findlast("%(")
            if last_index then
                variant_name = active_variant:sub(1, last_index - 1)
                variant_value = active_variant:sub(last_index, #active_variant).." -> "..enum_name
            end
        end

        enum_def_fields_string =
            "\n    --- "..active_variant_description:trim()..
            "\n    "..variant_name..": "..variant_value..
            enum_def_fields_string
    end

    for i = #lines, 1, -1 do
        line = lines[i]

        if line:startswith("-") and active_variant then
            line = line:sub(2)
            line = line:trim()

            active_variant_description = line.."\n"..active_variant_description
        else
            if active_variant then
                insert_active_enum()
            end

            active_variant = line:trim()
            active_variant_description = ""
        end
    end

    if active_variant then
        insert_active_enum()
    end

    enum_def_string = enum_def_string..enum_def_fields_string.."\nend"



    self:merge_str(enum_def_string)
    table.insert(self.found_enums, {
        name=enum_name,
        description=enum_description,
    })
end

function merger:merge_enum_files()
    local file_directory = "./enum_files"

    if is_windows then
        for dir in io.popen("dir \""..file_directory.."\" /b"):lines() do
            self:merge_enum_file(file_directory, dir)
        end
    else
        for dir in io.popen("ls -pa \""..file_directory.."\" | grep -v /"):lines() do
            self:merge_enum_file(file_directory, dir)
        end
    end

    local declare_enum_str = "declare Enum: {" 

    for _, v in pairs(self.found_enums) do
        declare_enum_str = declare_enum_str..
            "\n    --- "..v.description..
            "\n    "..v.name..": "..v.name.."Enums,"
    end
    declare_enum_str = declare_enum_str.."\n}"

    self:merge_str(declare_enum_str)
end

function merger:merge_actors()
    local actors_def = ""

    local definable_actors = {}

    for _, actor_info in ipairs(actors) do
        local inherited_actors = { actor_info }

        while true do
            local latest_actor = inherited_actors[1]
            if not latest_actor.extends then
                break
            end

            for _, v in pairs(actors) do
                if v.name == latest_actor.extends then
                    for _, v2 in pairs(inherited_actors) do
                        if v == v2 then
                            error("Extend loop detected")
                        end
                    end

                    table.insert(inherited_actors, 1, v)
                    break
                end
            end
        end

        local inherits_actor = {}

        local last_len = -1

        while last_len ~= #inherits_actor do
            last_len = #inherits_actor
            for _, actor_to_check in ipairs(actors) do

                if actor_to_check.extends == actor_info.name then

                    local add = true

                    for _, maybe_duplicate_actor in ipairs(inherits_actor) do
                        if actor_to_check == maybe_duplicate_actor then
                            add = false
                            break
                        end
                    end

                    if add then
                        table.insert(inherits_actor, actor_to_check)
                    end
                else

                    for _, v2 in ipairs(inherits_actor) do
                        if actor_to_check.extends == v2.name then

                            local add = true

                            for _, maybe_duplicate_actor in ipairs(inherits_actor) do
                                if actor_to_check == maybe_duplicate_actor then
                                    add = false
                                    break
                                end
                            end

                            if add then
                                table.insert(inherits_actor, actor_to_check)
                            end
                        end
                    end
                end
            end
        end

        if actor_info.define_name then
            table.insert(definable_actors, actor_info)
            local partial_type_def = "type Partial"..actor_info.name.." = {"
        
            for _, latest_actor in ipairs(inherited_actors) do
                for _, component_name in ipairs(latest_actor.components) do
                    local component = components[component_name]

                    if not component then
                        error("Component "..component_name.." does not exist")
                    end

                    for _, field in ipairs(component) do
                        if field.include_partial ~= false then
                            if field.type == "method" then
                                partial_type_def = partial_type_def..
                                    (field.comment and "\n    --- "..field.comment or "")..
                                    "\n    "..field.name..": ((self: "..actor_info.name..(field.args and ", "..field.args or "")..")  -> "..(field.returns and field.returns or "()")..")?,"
                            else
                                partial_type_def = partial_type_def..
                                    (field.comment and "\n    --- "..field.comment or "")..
                                    "\n    "..field.name..": "..field.type.."?,"
                            end
                        end
                    end
                end
            end
            partial_type_def = partial_type_def.."\n}"

            actors_def = actors_def..partial_type_def.."\n\n"
        end

        local class_def = "declare class "..actor_info.name.. (actor_info.extends and " extends "..actor_info.extends or "")

        for _, component_name in ipairs(actor_info.components) do
            local component = components[component_name]

            if not component then
                error("Component "..component_name.." does not exist")
            end

            for _, field in ipairs(component) do
                if field.include_actor ~= false then
                    if field.type == "method" then
                        class_def = class_def..
                            (field.comment and "\n    --- "..field.comment or "")..
                            "\n    function "..field.name.."(self"..(field.args and ", "..field.args or "")..")"..(field.returns and ": "..field.returns or "")
                    else
                        class_def = class_def..
                            (field.comment and "\n    --- "..field.comment or "")..
                            "\n    "..field.name..": "..field.type..(field.required == false and "?" or "")
                    end
                end
            end
        end

        local is_a_options = ""

        for _, inherits in ipairs(inherits_actor) do
            is_a_options = is_a_options..(is_a_options == "" and "\"" or " | \"")..inherits.name.."\""
        end

        if is_a_options ~= "" then
            class_def = class_def.."\n    function is_a(self, type: "..is_a_options.."): boolean"
        end

        local is_a_options = ""

        for _, inherited in ipairs(inherited_actors) do
            is_a_options = is_a_options..(is_a_options == "" and "\"" or " | \"")..inherited.name.."\""
        end

        if is_a_options ~= "" then
            class_def = class_def.."\n    function is_a(self, type: "..is_a_options.."): true"
        end

        local is_a_options = ""

        for _, actor in ipairs(actors) do
            local add = true
            for _, inherits in pairs(inherits_actor) do
                if inherits == actor or not add then
                    add = false
                    break
                end
            end
            for _, inherited in pairs(inherited_actors) do
                if inherited == actor or not add then
                    add = false
                    break
                end
            end
            if add then
                is_a_options = is_a_options..(is_a_options == "" and "\"" or " | \"")..actor.name.."\""
            end
        end

        if is_a_options ~= "" then
            class_def = class_def.."\n    function is_a(self, type: "..is_a_options.."): false"
        end
            

        class_def = class_def.."\nend"

        actors_def = actors_def..class_def.."\n\n"
    end

    actors_def = actors_def.."declare Create: {"

    for _, actor_info in ipairs(definable_actors) do
        actors_def = actors_def.."\n    "..actor_info.define_name..": ((data: Partial"..actor_info.name..") -> "..actor_info.name.."),"
    end
    
    actors_def = actors_def.."\n}"

    self:merge_str(actors_def)
end

return merger