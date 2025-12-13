return {
    {
        name="[number]",
        type="Actor2D",
    },
    {
        name="insert_child",
        type="method",
        args="child_actor: Actor2D, index: number?",
        include_partial=false,
    },
    {
        name="find_child",
        type="method",
        args="child_name: string",
        returns="Actor2D?",
        include_partial=false,
    },
}