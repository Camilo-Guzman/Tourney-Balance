local talent_api = {}

--[[
    Talent-tree-scoped registration: keyed by hero_name/career_name, reads or writes
    CareerSettings/TalentTrees/TalentIDLookup/Talents/TalentBuffTemplates. Generic
    buff/proc registration with no hero tie-in lives in the sibling file _buff_api.lua.

    insert_talent_buff_template/insert_talent silently overwrite an existing entry (or
    tree slot) with no warning if called again with the same name/position.
    update_talent_buff_template/update_talent require an existing entry and edit it in
    place. Full behavior, data shapes, and known quirks for each function: mod_api.md.
]]

function talent_api.update_career_ability_cooldown(hero_id, new_cooldown)
    ActivatedAbilitySettings[hero_id][1].cooldown = new_cooldown
end

function talent_api.insert_career_passives(hero_id, buffs)
    for _, buff in ipairs(buffs) do
        table.insert(PassiveAbilitySettings[hero_id].buffs, buff)   
    end
end

function talent_api.insert_career_perk_descriptions(hero_id, perk_name)
    local hero_passives = PassiveAbilitySettings[hero_id]
    local perks = hero_passives.perks

    perks[#perks + 1] = {
        display_name = "career_passive_name_" .. perk_name,
        description = "career_passive_desc_" .. perk_name,
    }
end

function talent_api.insert_talent_buff_template(hero_name, buff_name, buff_data, extra_data)
    local new_talent_buff = {
        buffs = {
            table.merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = table.merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end

function talent_api.update_talent_buff_template(hero_name, buff_name, buff_data, extra_data)
    local new_talent_buff = {
        buffs = {
            table.merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = table.merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    local merged_buff = original_buff
    for i=1, #original_buff.buffs do
        if new_talent_buff.buffs[i] then
            merged_buff.buffs[i] = table.merge(original_buff.buffs[i], new_talent_buff.buffs[i])
        --elseif original_buff[i] then -- needed for passives?
        --    merged_buff.buffs[i] = table.merge(original_buff.buffs[i], new_talent_buff.buffs)
        else
            merged_buff.buffs = table.merge(original_buff.buffs, new_talent_buff.buffs)
        end
    end

    TalentBuffTemplates[hero_name][buff_name] = merged_buff
    BuffTemplates[buff_name] = merged_buff
end

function talent_api.update_talent(career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = table.merge(old_talent_data, new_talent_data)
end

function talent_api.insert_talent(career_name, tier, index, new_talent_name, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index

    local new_talent_index = #Talents[hero_name] + 1

    Talents[hero_name][new_talent_index] = table.merge({
        name = new_talent_name,
        description = new_talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, new_talent_data)

    TalentTrees[hero_name][talent_tree_index][tier][index] = new_talent_name
    TalentIDLookup[new_talent_name] = {
        talent_id = new_talent_index,
        hero_name = hero_name
    }
end


return talent_api
