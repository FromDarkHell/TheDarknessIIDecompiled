local SwapMorphs = function(entity, inMorph, outMorph, time)
  if IsNull(entity) then
    return
  end
  local t = 0
  local weight
  while time > t do
    weight = t / time
    if not IsNull(entity) then
      entity:SetMorphValue(inMorph, weight)
      entity:SetMorphValue(outMorph, 1 - weight)
    end
    t = t + DeltaTime(0)
    Sleep(0)
  end
  if not IsNull(entity) then
    entity:SetMorphValue(outMorph, 0)
    entity:SetMorphValue(inMorph, 1)
  end
end
local MakeSomeNoise = function(avatar, morphTarget, morph, minWeight, time)
  local t = 0
  local weight
  local startWeight = 1
  local endWeight = Random(minWeight, 1)
  local weightDiff = startWeight - endWeight
  time = time / 2
  while t < time and not avatar:HasPostureModifier(Engine.PM_STAGGER) do
    weight = startWeight - t / time * weightDiff
    morphTarget:SetMorphValue(morph, weight)
    t = t + DeltaTime()
    Sleep(0)
  end
  t = 0
  while time > t and not avatar:HasPostureModifier(Engine.PM_STAGGER) do
    weight = endWeight + t / time * weightDiff
    morphTarget:SetMorphValue(morph, weight)
    t = t + DeltaTime()
    Sleep(0)
  end
  avatar:SetMorphValue(morph, 1)
end
local function PlayPainMorph(avatar, morphTarget, painMorph, currentMorph)
  SwapMorphs(morphTarget, painMorph, currentMorph, 0.1)
  local t = 0
  local time = 10
  while (avatar:HasPostureModifier(Engine.PM_STAGGER) or avatar:HasPostureModifier(Engine.PM_KNOCKDOWN)) and t < time do
    t = t + DeltaTime()
    Sleep(0.1)
  end
  SwapMorphs(morphTarget, currentMorph, painMorph, 0.2)
end
local function PlayGenericMorph(avatar, morphTarget, newMorph, currentMorph, time)
  if newMorph == currentMorph then
    MakeSomeNoise(avatar, morphTarget, newMorph, 0.25, 0.5)
  else
    SwapMorphs(morphTarget, newMorph, currentMorph, time)
  end
end
function OnMorphChangeRequested(avatar, target, newMorph, oldMorph)
  if oldMorph == Engine.BaseAvatar_FM_DEAD then
    return oldMorph
  end
  local newMorphName = avatar:GetFacialMorphName(newMorph)
  local oldMorphName = avatar:GetFacialMorphName(oldMorph)
  local morphTarget
  if not IsNull(target) then
    morphTarget = target
  else
    morphTarget = avatar
  end
  if newMorph == Engine.BaseAvatar_FM_PAIN then
    PlayPainMorph(avatar, morphTarget, newMorphName, oldMorphName)
    return oldMorph
  elseif newMorph == Engine.BaseAvatar_FM_DEAD then
    local ragdoll = avatar:GetRagdoll()
    if not IsNull(ragdoll) then
      PlayGenericMorph(ragdoll, morphTarget, newMorphName, oldMorphName, 0.05)
    else
      PlayGenericMorph(avatar, morphTarget, newMorphName, oldMorphName, 0.05)
    end
  else
    PlayGenericMorph(avatar, morphTarget, newMorphName, oldMorphName, 0.25)
  end
  return newMorph
end
