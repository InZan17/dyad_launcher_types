declare class Color
    r: number
    g: number
    b: number
end

declare Color: {
    from_rgb: ((r: number, g: number, b: number) -> Color),
    from_rgb_255: ((r: number, g: number, b: number) -> Color),
}