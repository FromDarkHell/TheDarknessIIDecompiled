SafetyZoneWaypoints = {
  Instance()
}
cowerAnim = Resource()
comfortDistance = 15
panicAnims = {
  Resource()
}
fleeSounds = {
  Resource()
}
fleeSoundChance = 33
cowerWhimperSounds = {
  Resource()
}
cowerWhimperChance = 33
local LocalCower = function(agent)
  agent:SetAllExits(false)
  local players = gRegion:GetHumanPlayers()
  local npcAvatar = agent:GetAvatar()
  local startingHealth = npcAvatar:GetHealth()
  local runAway = false
  while startingHealth == npcAvatar:GetHealth() and runAway == false do
    for i = 1, #players do
      local playerAvatar = players[i]:GetAvatar()
      local distance = Distance(playerAvatar:GetPosition(), npcAvatar:GetPosition())
      if distance < comfortDistance then
        runAway = true
        break
      end
    end
    if agent:HasActions() == false then
      agent:PlayAnimation(cowerAnim, false)
      if RandomInt(1, 100) <= cowerWhimperChance then
        local snd = RandomInt(1, #cowerWhimperSounds)
        npcAvatar:PlaySound(cowerWhimperSounds[snd], false)
      end
    end
    Sleep(0)
  end
  if RandomInt(1, 100) <= fleeSoundChance then
    local snd = RandomInt(1, #fleeSounds)
    npcAvatar:PlaySound(fleeSounds[snd], false)
  end
  local pos = RandomInt(1, #SafetyZoneWaypoints)
  agent:MoveTo(SafetyZoneWaypoints[pos], true, true, true)
  agent:StopScriptedMode()
end
local LocalPanicandFlee = function(agent)
  agent:SetAllExits(false)
  local animnum = RandomInt(1, #panicAnims)
  local npcAvatar = agent:GetAvatar()
  if RandomInt(1, 100) <= fleeSoundChance then
    local snd = RandomInt(1, #fleeSounds)
    npcAvatar:PlaySound(fleeSounds[snd], false)
  end
  local pos = RandomInt(1, #SafetyZoneWaypoints)
  agent:MoveTo(SafetyZoneWaypoints[pos], true, true, false)
  while agent:HasActions() == true do
    if agent:LastActionFailed() == true then
      agent:MoveTo(SafetyZoneWaypoints[pos], true, true, true)
    end
    Sleep(0)
  end
  agent:StopScriptedMode()
end
local LocalFlee = function(agent)
  agent:SetAllExits(false)
  local npcAvatar = agent:GetAvatar()
  local pos = RandomInt(1, #SafetyZoneWaypoints)
  if RandomInt(1, 100) <= fleeSoundChance then
    local snd = RandomInt(1, #fleeSounds)
    npcAvatar:PlaySound(fleeSounds[snd], false)
  end
  agent:MoveTo(SafetyZoneWaypoints[pos], true, true, true)
  if agent:LastActionFailed() == true then
    agent:MoveTo(SafetyZoneWaypoints[pos], true, true, true)
  end
  agent:StopScriptedMode()
end
function RandomizedPanic(agent)
  local num = RandomInt(0, 2)
  if num == 0 then
    LocalCower(agent)
  elseif num == 1 then
    LocalPanicandFlee(agent)
  else
    LocalFlee(agent)
  end
end
function Cower(agent)
  LocalCower(agent)
end
function PanicandFlee(agent)
  LocalPanicandFlee(agent)
end
function Flee(agent)
  LocalFlee(agent)
end
