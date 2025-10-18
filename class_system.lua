--[[
    Garry's Mod Lua Script
    Author: GMOD Lua Assistant (GPT-5)
    Description:
        Provides customizable class system for:
        - A main team (1–5 players)
        - A solo team (1 player)
--]]

-- =============== TEAM SETUP ===============

TEAM_MAIN = 1
TEAM_SOLO = 2

team.SetUp(TEAM_MAIN, "Main Squad", Color(50, 150, 255))
team.SetUp(TEAM_SOLO, "Lone Wolf", Color(255, 100, 50))

-- =============== CLASS DEFINITIONS ===============

local Classes = {
    ["Soldier"] = {
        health = 120,
        armor = 50,
        speed = 1.0,
        weaponLoadout = {"weapon_ar2", "weapon_pistol"},
        description = "Frontline fighter with balanced stats."
    },
    ["Medic"] = {
        health = 100,
        armor = 25,
        speed = 1.1,
        weaponLoadout = {"weapon_pistol", "weapon_medkit"},
        description = "Supports the team by healing others."
    },
    ["Engineer"] = {
        health = 110,
        armor = 40,
        speed = 0.95,
        weaponLoadout = {"weapon_smg1", "weapon_toolgun"},
        description = "Builds and repairs structures."
    }
}

-- Solo team has special customizable attributes
local SoloAttributes = {
    health = 150,
    armor = 75,
    speed = 1.15,
    weaponLoadout = {"weapon_shotgun", "weapon_crowbar"},
    description = "Operates alone with enhanced stats."
}

-- =============== ATTRIBUTE APPLICATION ===============

local function ApplyAttributes(ply, attributes)
    if not IsValid(ply) or not attributes then return end

    ply:SetHealth(attributes.health or 100)
    ply:SetArmor(attributes.armor or 0)
    ply:SetRunSpeed(250 * (attributes.speed or 1))
    ply:SetWalkSpeed(200 * (attributes.speed or 1))

    if attributes.weaponLoadout then
        timer.Simple(0.1, function()
            if not IsValid(ply) then return end
            ply:StripWeapons()
            for _, wep in ipairs(attributes.weaponLoadout) do
                ply:Give(wep)
            end
        end)
    end
end

-- =============== PLAYER SPAWN HANDLER ===============

hook.Add("PlayerSpawn", "GMOD_ClassSystem_Spawn", function(ply)
    local teamID = ply:Team()

    if teamID == TEAM_MAIN then
        -- Default class if not chosen
        local className = ply.SelectedClass or "Soldier"
        ApplyAttributes(ply, Classes[className])
        ply:ChatPrint("[Class System] You are a " .. className .. ".")
    elseif teamID == TEAM_SOLO then
        ApplyAttributes(ply, SoloAttributes)
        ply:ChatPrint("[Class System] You are the Lone Wolf.")
    end
end)

-- =============== CLASS SELECTION COMMANDS ===============

util.AddNetworkString("GMOD_Class_Select")

concommand.Add("select_class", function(ply, cmd, args)
    if ply:Team() ~= TEAM_MAIN then
        ply:ChatPrint("Only main team members can select classes.")
        return
    end

    local className = args[1]
    if not className or not Classes[className] then
        ply:ChatPrint("Invalid class. Available: Soldier, Medic, Engineer")
        return
    end

    ply.SelectedClass = className
    ply:ChatPrint("You have selected class: " .. className)
end)

-- =============== CUSTOMIZATION API ===============

-- Allow gamemodes or addons to override or add new classes
function AddCustomClass(name, attributes)
    if not name or not istable(attributes) then return end
    Classes[name] = attributes
    print("[Class System] Added custom class: " .. name)
end

function SetSoloAttributes(attributes)
    if not istable(attributes) then return end
    SoloAttributes = attributes
    print("[Class System] Solo attributes updated.")
end
