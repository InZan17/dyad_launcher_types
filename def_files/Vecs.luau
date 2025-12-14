declare class Vec2
    x: number
    y: number
    function __div(self, rhs: Vec2)
end

declare Vec2: {
    new: ((x: number, y: number) -> Vec2)
}

declare class Vec3
    x: number
    y: number
    z: number
end

declare Vec3: {
    new: ((x: number, y: number, z: number) -> Vec3)
}