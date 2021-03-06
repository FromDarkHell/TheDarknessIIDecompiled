healthValues = {
  100,
  200,
  400,
  500
}
npcAvatarType = Type()
hudMovie = WeakResource()
deathAnim = Resource()
deathAnimLength = 3.1
FirstHealthEventThreshold = 75
MidHealthEventThreshold = 50
FinalHealthEventThreshold = 25
FirstHealthEventTimer = Instance()
MidHealthEventTimer = Instance()
FinalHealthEventTimer = Instance()
FirstHealthEventSound = Instance()
MidHealthEventSound = Instance()
FinalHealthEventSound = Instance()
local movieInstance
local prevHealthPct = 0
local minHealth = 200
function OnSpawn(agent)
  local diff = gRegion:GetGameRules():GetCurrentDifficulty()
  local avatar = agent:GetAvatar()
  avatar:SetMaxHealth(healthValues[diff + 1])
  avatar:SetHealth(healthValues[diff + 1])
end
function UpdateMPBoss()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local doneyetA = false
  local doneyetB = false
  local doneyetC = false
  while avatar:GetHealth() > 0 do
    Sleep(0)
    local healthpercent = avatar:GetHealth() / avatar:GetMaxHealth() * 100
    if healthpercent < FirstHealthEventThreshold and doneyetA == false then
      FirstHealthEventTimer:FirePort("Start")
      FirstHealthEventSound:FirePort("Enable")
      doneyetA = true
    elseif healthpercent < MidHealthEventThreshold and doneyetB == false then
      MidHealthEventTimer:FirePort("Start")
      MidHealthEventSound:FirePort("Enable")
      doneyetB = true
    elseif healthpercent < FinalHealthEventThreshold and doneyetC == false then
      FinalHealthEventTimer:FirePort("Start")
      FinalHealthEventSound:FirePort("Enable")
      doneyetC = true
    end
  end
end
