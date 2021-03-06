RainB = Type()
RainC = Type()
screenRain = Type()
MaterialMult = 2
NewSpew = 10
OriginalValue = 1
PlayerRainCone = Symbol()
transitionTime = 5
MainRainType = Type()
KillAfterFade = false
function TurnRainUp()
  local levelInfo = gRegion:GetLevelInfo()
  local parent = gRegion:FindTagged(PlayerRainCone)
  local mainRain
  local tempVal = MaterialMult
  if not IsNull(parent) then
    for i = 1, #parent do
      local temp = parent[i]
      temp:Destroy()
    end
  end
  local player = gRegion:GetPlayerAvatar()
  mainRain = player:Attach(MainRainType, Symbol(), Vector(), Rotation())
  local screen = mainRain:GetAttachment(screenRain)
  local rainChildB = mainRain:GetAttachment(RainB)
  local rainChildC = mainRain:GetAttachment(RainC)
  if not IsNull(screen) then
    screen:SetSpewCount(NewSpew, NewSpew)
  end
  local t = 0
  local val = 1
  while t < transitionTime do
    val = OriginalValue + (MaterialMult - OriginalValue) * t / transitionTime
    mainRain:SetMaterialParam("Scalar1", val)
    mainRain:SetMaterialParam("Scalar2", val)
    rainChildB:SetMaterialParam("Scalar1", val)
    rainChildB:SetMaterialParam("Scalar2", val)
    rainChildC:SetMaterialParam("Scalar1", val)
    rainChildC:SetMaterialParam("Scalar2", val)
    t = t + DeltaTime()
    Sleep(0)
  end
  if KillAfterFade then
    mainRain:Destroy()
  end
end
function AttachRain()
  local parent = gRegion:FindTagged(PlayerRainCone)
  local mainRain
  if not IsNull(parent) then
    for i = 1, #parent do
      local temp = parent[i]
      temp:Destroy()
    end
  end
  local player = gRegion:GetPlayerAvatar()
  mainRain = player:Attach(MainRainType, Symbol(), Vector(), Rotation())
end
