declare class Quat
    x: number
    y: number
    z: number
    w: number
end

declare Quat: {
    new: ((x: number, y: number, z: number, w: number) -> Quat),
    from_axis_angle: ((axis: Vec3, angle: number) -> Quat),
    from_euler_xyz: ((x: number, y: number, z: number) -> Quat),
}