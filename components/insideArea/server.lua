return {
    label = "Inside Area",
    parameters = {
        {label = "Position", name = "position", required = true, validation = function(input) 
            return (input and type(input) == "table" and input.x and input.y and input.z)
        end},
        {label = "Distance", name = "distance", required = true, default = 1.5, validation = function(input) 
            return (input and type(input) == "number" and input > 1.5)
        end}
    },
    events = {
        requestCompletion = function(source, id, params)
        end
    }
}