local random_utils = {}

--[[
    shuffle_bag(items) returns a draw() function implementing a Fisher-Yates
    shuffle bag: every item in `items` is drawn exactly once, in random
    order, before any repeat - avoids the streaks/skips of independent
    math.random() rolls when picking among a small fixed set of outcomes.

    roll_virtual_bag(bag_state, total_size, winning_draws) is a fair
    "is this draw a winner" evaluator (Floyd's random sample algorithm):
    across every total_size calls, exactly winning_draws of them return
    true, spread pseudo-randomly - bounding worst-case drought/streak
    length instead of letting independent math.random() rolls cluster.
    bag_state is a plain table the caller owns and passes back in on every
    call; it's mutated in place to persist draw progress between calls.
]]
function random_utils.shuffle_bag(items)
    local bag = {}

    return function()
        if #bag == 0 then
            for i = 1, #items do
                bag[i] = items[i]
            end
            for i = #bag, 2, -1 do
                local j = math.random(i)
                bag[i], bag[j] = bag[j], bag[i]
            end
        end

        return table.remove(bag)
    end
end

function random_utils.roll_virtual_bag(bag_state, total_size, winning_draws)
    -- If the bag is uninitialized or exhausted, generate a new set of targets
    if not bag_state.draw_count or bag_state.draw_count > total_size then
        bag_state.draw_count = 1
        bag_state.targets = {}

        -- Floyd's random sample algorithm
        local start_val = total_size - winning_draws + 1
        for j = start_val, total_size do
            local r = math.random(1, j)

            if bag_state.targets[r] then
                bag_state.targets[j] = true
            else
                bag_state.targets[r] = true
            end
        end
    end

    -- Check if the current draw is a winner
    local is_winner = bag_state.targets[bag_state.draw_count] or false

    -- Increment for the next time this function is called
    bag_state.draw_count = bag_state.draw_count + 1

    return is_winner
end

return random_utils
