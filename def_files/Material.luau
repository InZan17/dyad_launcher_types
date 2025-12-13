declare class Material
    function set_texture(self, name: string, texture: Texture)
    function clone(self): Material
    function set_float1(self, name: string, f1: number)
    function set_float2(self, name: string, f1: number, f2: number)
    function set_float3(self, name: string, f1: number, f2: number, f3: number)
    function set_float4(self, name: string, f1: number, f2: number, f3: number, f4: number)
    function set_int1(self, name: string, i1: number)
    function set_int2(self, name: string, i1: number, i2: number)
    function set_int3(self, name: string, i1: number, i2: number, i3: number)
    function set_int4(self, name: string, i1: number, i2: number, i3: number, i4: number)
end

declare create_material: (data: {
    frag: string?,
    vert: string?,
    uniforms: {any}?
}) -> Material