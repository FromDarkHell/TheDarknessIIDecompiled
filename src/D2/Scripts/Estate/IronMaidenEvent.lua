hudMovie = WeakResource()
crankerSpawnControl = Instance()
ironMaiden = Instance()
ironMaidenEndPos = Instance()
ironMaidenLandPos = Instance()
ironMaidenPostCin = Instance()
hardFailScriptInstance = Instance()
eventTime = 45
maidenLandSound = Instance()
ironMaidenLandSoundPercentage = 0.85
ironMaidenTime = 110
local crankerKilled = false
local speedMult = 1
local g = 0.81725
function OnAgentDestroyed(entity)
  crankerKilled = true
end
function OnAgentAlerted(entity)
  speedMult = 0
end
function Start()
  local t = 0
  local ironMaidenStartPos = ironMaiden:GetPosition()
  local darklingPlayerAvatar = gRegion:GetPlayerAvatar()
  local playerHealth = darklingPlayerAvatar:GetHealth()
  if IsNull(crankerSpawnControl) == false then
    ObjectPortHandler(crankerSpawnControl, "OnAgentDestroyed")
    ObjectPortHandler(crankerSpawnControl, "OnAgentAlerted")
  end
  while t < ironMaidenTime and crankerKilled == false do
    if IsNull(darklingPlayerAvatar) == false then
      playerHealth = darklingPlayerAvatar:GetHealth()
      if playerHealth <= 0 then
        speedMult = 1
      end
    end
    local emiss = math.pow(2.718, t - 28.5)
    local boundedEmiss = math.min(emiss, 2)
    local updatePos = LerpVector(ironMaidenStartPos, ironMaidenEndPos:GetPosition(), t / ironMaidenTime)
    ironMaiden:SetMaterialParam("EmissiveMapAtten", boundedEmiss)
    ironMaiden:SetPosition(updatePos)
    t = t + DeltaTime() * speedMult
    Sleep(0)
  end
  while crankerKilled == false do
    Sleep(0)
  end
  t = 0
  local maidenPos = ironMaiden:GetPosition()
  local landSoundPlayed = false
  Sleep(1)
  while t < 1 do
    local v = g * t
    local d = v * t
    maidenPos.y = maidenPos.y - d
    if maidenPos.y <= ironMaidenLandPos:GetPosition().y then
      maidenPos.y = ironMaidenLandPos:GetPosition().y
    end
    ironMaiden:SetPosition(maidenPos)
    t = t + DeltaTime()
    if t > ironMaidenLandSoundPercentage and landSoundPlayed == false and IsNull(maidenLandSound) == false then
      maidenLandSound:FirePort("Enable")
      landSoundPlayed = true
    end
    Sleep(0)
  end
  ironMaidenPostCin:SetMaterialParam("EmissiveMapAtten", 2)
end
