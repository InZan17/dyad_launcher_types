declare class CharEvent
    char: string
    character: string
    ctrl: boolean
    alt: boolean
    shift: boolean
    logo: boolean
    ["repeat"]: boolean
end

declare class InputEventInfo
    mouse_pos: Vec2
    scroll: Vec2
    char_events: { CharEvent }
    key_downs: { string }
    key_holds: { string }
    key_ups: { string }
    mouse_downs: { string }
    mouse_holds: { string }
    mouse_ups: { string }

    function is_mouse_primary_pressed(self): boolean
    function is_mouse_secondary_pressed(self): boolean
    function is_mouse_middle_pressed(self): boolean
    function is_mouse_unknown_pressed(self): boolean

    function is_mouse_primary_held(self): boolean
    function is_mouse_secondary_held(self): boolean
    function is_mouse_middle_held(self): boolean
    function is_mouse_unknown_held(self): boolean

    function is_mouse_primary_released(self): boolean
    function is_mouse_secondary_released(self): boolean
    function is_mouse_middle_released(self): boolean
    function is_mouse_unknown_released(self): boolean

    function is_key_pressed(self, key: string): boolean
    function is_key_held(self, key: string): boolean
    function is_key_released(self, key: string): boolean
end

declare input: InputEventInfo