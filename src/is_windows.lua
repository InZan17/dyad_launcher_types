local function get_os_name()
    local os_type = os.getenv("OS")

    if os_type ~= nil then
        return os_type
    end

    local uname = io.popen("uname -s"):read("*l")

    if uname ~= nil then
        return uname
    end

    return "Unknown"
end

return get_os_name() == "Windows_NT"