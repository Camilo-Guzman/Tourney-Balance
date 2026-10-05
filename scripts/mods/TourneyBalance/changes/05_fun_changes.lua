local mod = get_mod("TourneyBalance")

--[[
    Jump Cancelling

    Was Handmaiden-only (see git history on 10_we_maidenguard.lua). Now available to every career,
    gated behind the "Fun Features" mod settings (Jump-Cancel Dodges / Jump-Cancel Dashes), since it
    changes core movement feel and not everyone wants it on.
--]]

local function tb_noop() end

-- Settings cached here and refreshed only on actual change (TourneyBalance.lua's
-- mod:add_setting_changed_function dispatcher), instead of calling mod:get() every frame in the
-- PlayerCharacterStateLunging.update hook below, which runs every frame while dashing.
local jump_cancel_dodges_enabled = mod:get("jump_cancel_dodges")
local jump_cancel_dashes_enabled = mod:get("jump_cancel_dashes")

mod:add_setting_changed_function(function ()
    jump_cancel_dodges_enabled = mod:get("jump_cancel_dodges")
    jump_cancel_dashes_enabled = mod:get("jump_cancel_dashes")
end)

-- PlayerCharacterStateLunging.on_enter unconditionally calls whereabouts_extension:set_jumped()
mod:hook(PlayerCharacterStateLunging, "on_enter", function (func, self, unit, input, dt, context, t, previous_state, params)
    local silence_set_jumped = jump_cancel_dashes_enabled and (previous_state == "jumping" or previous_state == "falling")

    if not silence_set_jumped then
        return func(self, unit, input, dt, context, t, previous_state, params)
    end

    local whereabouts_extension = ScriptUnit.extension(unit, "whereabouts_system")
    local real_set_jumped = whereabouts_extension.set_jumped

    whereabouts_extension.set_jumped = tb_noop

    func(self, unit, input, dt, context, t, previous_state, params)

    whereabouts_extension.set_jumped = real_set_jumped
end)

-- Jump cancel out of a dash (career skills that lunge you forward, e.g. Handmaiden's Dash)
local JUMP_CANCEL_MOMENTUM_MODIFIER = 1.0
mod:hook(PlayerCharacterStateLunging, "update", function (func, self, unit, input, dt, context, t)
    if jump_cancel_dashes_enabled and not self.csm.state_next then
        local input_extension = self.input_extension
        local locomotion_extension = self.locomotion_extension

        if (input_extension:get("jump") or input_extension:get("jump_only")) and locomotion_extension:jump_allowed() then
            local lunge_data = self._lunge_data
            local lunge_time = t - self._start_time
            local duration = lunge_data.duration
            local speed_function = lunge_data.speed_function
            local speed

            if speed_function then
                speed = speed_function(lunge_time, duration)
            else
                speed = math.lerp(lunge_data.initial_speed, lunge_data.falloff_to_speed, math.min(lunge_time / duration, 1))
            end

            local move_direction

            if lunge_data.allow_rotation then
                local forward_direction = Quaternion.forward(self.first_person_extension:current_rotation())

                move_direction = Vector3.normalize(Vector3.flat(forward_direction))
            else
                move_direction = self._direction:unbox()
            end

            local dash_velocity = move_direction * speed * JUMP_CANCEL_MOMENTUM_MODIFIER

            local whereabouts_extension = ScriptUnit.extension(unit, "whereabouts_system")
            local real_set_jumped = whereabouts_extension.set_jumped

            whereabouts_extension.set_jumped = tb_noop

            self.status_extension._tb_dash_jump_velocity = Vector3Box(dash_velocity)

            self.csm:change_state("jumping", self.temp_params)
            self.first_person_extension:change_state("jumping")

            whereabouts_extension.set_jumped = real_set_jumped

            return
        end
    end

    return func(self, unit, input, dt, context, t)
end)

-- Jump cancel out of a dodge
mod:hook(PlayerCharacterStateJumping, "on_enter", function (func, self, unit, input, dt, context, t, previous_state, params)
    local dodge_jump_velocity, dodge_jump_speed

    if jump_cancel_dodges_enabled and previous_state == "dodging" and params.post_dodge_jump then
        dodge_jump_velocity = Vector3.flat(self.locomotion_extension:current_velocity()) * JUMP_CANCEL_MOMENTUM_MODIFIER
        dodge_jump_speed = Vector3.length(dodge_jump_velocity)
    end

    func(self, unit, input, dt, context, t, previous_state, params)

    local locomotion_extension = self.locomotion_extension
    local status_extension = self.status_extension
    local preserved_velocity_box = status_extension._tb_dash_jump_velocity

    if preserved_velocity_box then
        status_extension._tb_dash_jump_velocity = nil

        local dash_velocity = preserved_velocity_box:unbox()
        local dash_speed = Vector3.length(dash_velocity)

        if dash_speed > 0 then
            locomotion_extension:set_external_velocity_enabled(true)
            locomotion_extension:add_external_velocity(dash_velocity, dash_speed)
        end
    elseif dodge_jump_speed and dodge_jump_speed > 0 then
        locomotion_extension:set_external_velocity_enabled(true)
        locomotion_extension:add_external_velocity(dodge_jump_velocity, dodge_jump_speed)
    end
end)
