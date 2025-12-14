return {
    {
        name="[number]",
        type="Actor3D",
    },
    {
        name="insert_child",
        type="method",
        args="child_actor: Actor3D, index: number?",
        include_partial=false,
    },
    {
        name="find_child",
        type="method",
        args="child_name: string",
        returns="Actor3D?",
        include_partial=false,
    },
}