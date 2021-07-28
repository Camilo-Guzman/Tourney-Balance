local mod = get_mod("TourneyBalance")

-- Text Localization
local _language_id = Application.user_setting("language_id")
local _localization_database = {}
mod._quick_localize = function (self, text_id)
    local mod_localization_table = _localization_database
    if mod_localization_table then
        local text_translations = mod_localization_table[text_id]
        if text_translations then
            return text_translations[_language_id] or text_translations["en"]
        end
    end
end
function mod.add_text(self, text_id, text)
    if type(text) == "table" then
        _localization_database[text_id] = text
    else
        _localization_database[text_id] = {
            en = text
        }
    end
end
mod:hook("Localize", function(func, text_id)
    local str = mod:_quick_localize(text_id)
    if str then return str end
    return func(text_id)
end)

-- THP & Stagger Talent Functions & Changes
mod:dofile("scripts/mods/TourneyBalance/changes/thp_stagger_changes")

-- Talent Changes
mod:dofile("scripts/mods/TourneyBalance/changes/talent_changes")

-- Weapon Changes
mod:dofile("scripts/mods/TourneyBalance/changes/weapon_changes")

-- Career Changes (Passives, Ultimates, etc.)
mod:dofile("scripts/mods/TourneyBalance/changes/career_changes")

-- on_remove_stack_down
mod:hook_origin(BuffExtension, "remove_buff", function (self, id, buff_type, delayed, full_remove)
	local buffs = self._buffs
	local num_buffs = #buffs
	local end_time = Managers.time:time("game")
	local num_buffs_removed = 0
	local i = 1

	while num_buffs >= i do
		local buff = buffs[i]
		local template = buff.template
		buff_extension_function_params.bonus = buff.bonus
		buff_extension_function_params.multiplier = buff.multiplier
		buff_extension_function_params.value = buff.value
		buff_extension_function_params.t = end_time
		buff_extension_function_params.end_time = end_time
		buff_extension_function_params.attacker_unit = buff.attacker_unit

		if (id and buff.id == id) or (buff.parent_id and id and buff.parent_id == id) or (buff_type and buff.buff_type == buff_type) then
            local on_remove_stack_down = template.on_remove_stack_down
			if delayed then
				buff.duration = 0
				i = i + 1
            elseif on_remove_stack_down and not full_remove then
                self:_remove_sub_buff(buff, i, buff_extension_function_params)

				local new_buff_count = #buffs
				num_buffs_removed = num_buffs_removed + num_buffs - new_buff_count
				num_buffs = new_buff_count
                self._buffs[i].start_time = Managers.time:time("game")
            else
				self:_remove_sub_buff(buff, i, buff_extension_function_params)

				local new_buff_count = #buffs
				num_buffs_removed = num_buffs_removed + num_buffs - new_buff_count
				num_buffs = new_buff_count
			end
		else
			i = i + 1
		end
	end

	if num_buffs == 0 then
		Managers.state.entity:system("buff_system"):set_buff_ext_active(self._unit, false)
	end

	return num_buffs_removed
end)
mod:hook_origin(BuffExtension, "update", function (self, unit, input, dt, context, t)
	local world = self.world
	local buffs = self._buffs
	local unit = self._unit
	local num_buffs = #buffs
	local i = 1
	local buff_extension_function_params = buff_extension_function_params
    local on_remove_stack_down_done = {}

	while i <= num_buffs do
		local buff = buffs[i]
		local template = buff.template

		local end_time = buff.duration and buff.start_time + buff.duration
		buff_extension_function_params.bonus = buff.bonus
		buff_extension_function_params.multiplier = buff.multiplier
		buff_extension_function_params.value = buff.value
		buff_extension_function_params.t = t
		buff_extension_function_params.end_time = end_time
		buff_extension_function_params.attacker_unit = buff.attacker_unit
		buff_extension_function_params.source_attacker_unit = buff.source_attacker_unit

		if end_time and end_time <= t then
            local on_remove_stack_down = template.on_remove_stack_down
            local buff_name = template.name
            if on_remove_stack_down and on_remove_stack_down_done[buff_name] == nil then
                local current_stacks = self:num_buff_type(buff_name)

                self:_remove_sub_buff(buff, i, buff_extension_function_params)
                on_remove_stack_down_done[buff_name] = true

                if current_stacks == 1 then
                    if template.buff_after_delay and not buff.aborted then
                        local delayed_buff_name = buff.delayed_buff_name
    
                        if buff.delayed_buff_params then
                            local delayed_buff_params = buff.delayed_buff_params
    
                            self:add_buff(delayed_buff_name, delayed_buff_params)
                        else
                            self:add_buff(delayed_buff_name)
                        end
                    end
                end
            elseif on_remove_stack_down and on_remove_stack_down_done[buff_name] then
                buff.start_time = t
            else
                self:_remove_sub_buff(buff, i, buff_extension_function_params)

                if template.buff_after_delay and not buff.aborted then
                    local delayed_buff_name = buff.delayed_buff_name

                    if buff.delayed_buff_params then
                        local delayed_buff_params = buff.delayed_buff_params

                        self:add_buff(delayed_buff_name, delayed_buff_params)
                    else
                        self:add_buff(delayed_buff_name)
                    end
                end
            end
		else
			local update_func = template.update_func

			if update_func then
				local next_update_t = buff._next_update_t

				if not next_update_t then
					next_update_t = t + (buff.template.update_start_delay or 0)
					buff._next_update_t = next_update_t
				end

				if not next_update_t or next_update_t <= t then
					local time_into_buff = t - buff.start_time
					local time_left_on_buff = end_time and end_time - t
					buff_extension_function_params.time_into_buff = time_into_buff
					buff_extension_function_params.time_left_on_buff = time_left_on_buff

					BuffFunctionTemplates.functions[update_func](unit, buff, buff_extension_function_params, world)

					buff._next_update_t = t + (buff.template.update_frequency or 0)
				end
			end

			i = i + 1
		end

		num_buffs = #buffs
	end

	if num_buffs == 0 then
		Managers.state.entity:system("buff_system"):set_buff_ext_active(unit, false)
	end
end)


local function updateValues()
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return

end

mod.on_enabled = function (self)
	mod:echo("enable")
	updateValues()

	return
end