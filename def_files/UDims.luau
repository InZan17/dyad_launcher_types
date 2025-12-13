declare class UDim
    rel: number
    rel_x: number
    rel_y: number
    inch: number
    px: number

    __add: (UDim, UDim) -> UDim
    __sub: (UDim, UDim) -> UDim
end

declare UDim: {
    new: ((px: number, inch: number, rel: number, rel_x: number, rel_y: number) -> UDim),
    px: ((px: number) -> UDim),
    inch: ((inch: number) -> UDim),
    rel: ((rel: number) -> UDim),
    rel_x: ((rel_x: number) -> UDim),
    rel_y: ((rel_y: number) -> UDim),
}

declare px: ((px: number) -> UDim)
declare inch: ((inch: number) -> UDim)
declare rel: ((rel: number) -> UDim)
declare rel_x: ((rel_x: number) -> UDim)
declare rel_y: ((rel_y: number) -> UDim)


declare class UDim2
    x: UDim
    y: UDim

    __add: (UDim2, UDim2) -> UDim2
    __sub: (UDim2, UDim2) -> UDim2
end

declare UDim2: {
    new: ((x: UDim | number, y: UDim | number) -> UDim2),
}