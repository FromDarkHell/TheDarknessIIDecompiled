headTypes = {
  Type()
}
armorType = Type()
effectsType = Type()
weaponType = Type()
headTintsDark = {
  Resource()
}
headTintsLight = {
  Resource()
}
tintColour = Color()
maxAtten = 6
minAtten = 0
armorMorphTime = 1.5
local MapToRange = function(t, x, y)
  local m = t - x
  m = math.min(m, y)
  m = m / (y - x)
  m = Clamp(m, 0, 1)
  return m
end
local InterpolateParam = function(deco, param, startVal, endVal, interTime)
  local t = 0
  local val
  if 0 < #deco then
    while t < 1 do
      for i = 1, #deco do
        val = Lerp(startVal, endVal, t)
        if IsNull(deco[i]) == false then
          deco[i]:SetMaterialParam(param, val)
        end
        t = t + DeltaTime() / interTime
        Sleep(0)
      end
    end
  end
  for i = 1, #deco do
    if IsNull(deco[i]) == false then
      deco[i]:SetMaterialParam(param, endVal)
    end
  end
end
local CloakObject = function(deco, time)
  if IsNull(deco) == true then
    return
  end
  local startDissolve = deco:GetDissolve()
  time = time * (1 - startDissolve)
  local t = 0
  while time > t do
    deco:SetDissolve(Lerp(startDissolve, 1, t / time))
    t = t + DeltaTime()
    Sleep(0)
  end
  deco:SetDissolve(1)
end
local UncloakObject = function(deco)
  if IsNull(deco) == true then
    return
  end
  local startDissolve = deco:GetDissolve()
  local time = startDissolve
  local t = 0
  while time > t do
    deco:SetDissolve(Lerp(0, startDissolve, 1 - t / time))
    t = t + DeltaTime()
    Sleep(0)
  end
  deco:SetDissolve(0)
end
local SetTint = function(deco, colour)
  for i = 1, #deco do
    if not IsNull(deco[i]) then
      deco[i]:SetMaterialParam("EmissiveTintColor", colour.red / 255, colour.green / 255, colour.blue / 255, colour.alpha / 255)
    end
  end
end
local SetArmorMorphs = function(entity, val)
  entity:SetMorphValue(Symbol("BlendShapes.Face"), val)
  entity:SetMorphValue(Symbol("BlendShapes.Arm1Upper"), val)
  entity:SetMorphValue(Symbol("BlendShapes.Arm2Lower"), val)
  entity:SetMorphValue(Symbol("BlendShapes.Torso"), val)
  entity:SetMorphValue(Symbol("BlendShapes.Hand"), val)
end
local function UpdateSimpleArmorMorphs(entity, t)
  t = MapToRange(t, 0, 1)
  entity:SetMorphValue(Symbol("BlendShapes.HideAll"), t)
end
local function UpdateArmorMorphs(entity, t)
  t = MapToRange(t, 0, 1)
  local face = MapToRange(t, 0.6, 1)
  local torso = MapToRange(t, 0.4, 0.8)
  local armUpper = MapToRange(t, 0.2, 0.6)
  local armLower = MapToRange(t, 0, 0.4)
  local hand = MapToRange(t, 0, 0.2)
  entity:SetMorphValue(Symbol("BlendShapes.HideAll"), 0)
  entity:SetMorphValue(Symbol("BlendShapes.Face"), face)
  entity:SetMorphValue(Symbol("BlendShapes.Arm1Upper"), armUpper)
  entity:SetMorphValue(Symbol("BlendShapes.Arm2Lower"), armLower)
  entity:SetMorphValue(Symbol("BlendShapes.Torso"), torso)
  entity:SetMorphValue(Symbol("BlendShapes.Hand"), hand)
end
local function MorphArmor(armor, lightStatus)
  local t = 0
  while t < 1 do
    if lightStatus == "DARK" then
      UpdateSimpleArmorMorphs(armor, 1 - t)
    else
      UpdateSimpleArmorMorphs(armor, t)
    end
    t = t + DeltaTime() / armorMorphTime
    Sleep(0)
  end
  if lightStatus == "DARK" then
    SetArmorMorphs(armor, 0)
  else
    SetArmorMorphs(armor, 1)
  end
end
local function MorphLoop(avatar)
  local armor = avatar:GetAttachment(armorType)
  local morphTime = 1
  while true do
    local t = 0
    while t < 1 do
      UpdateSimpleArmorMorphs(armor, t)
      t = t + DeltaTime() / morphTime
      Sleep(0)
    end
    t = 0
    while t < 1 do
      UpdateSimpleArmorMorphs(armor, 1 - t)
      t = t + DeltaTime() / morphTime
      Sleep(0)
    end
    Sleep(1)
  end
end
local function BrotherhoodArmor(avatar, lightStatus)
  local armor = avatar:GetAttachment(armorType)
  local weapon
  if IsNull(weaponType) == false then
    weapon = avatar:GetAttachment(weaponType)
  end
  local head
  for i = 1, #headTypes do
    head = avatar:GetAttachment(headTypes[i])
    if IsNull(head) == false then
      if lightStatus == "LIGHT" then
        head:SetOverrideMaterial(0, headTintsLight[i])
        break
      end
      head:SetOverrideMaterial(0, headTintsDark[i])
      break
    end
  end
  SetTint({
    head,
    avatar,
    armor,
    weapon
  }, tintColour)
  if IsNull(armor) == false then
    MorphArmor(armor, lightStatus)
  end
  if lightStatus == "LIGHT" then
    InterpolateParam({
      head,
      avatar,
      armor,
      weapon
    }, "EmissiveMapAtten", maxAtten, minAtten, 2)
  elseif lightStatus == "DARK" then
    InterpolateParam({
      head,
      avatar,
      armor,
      weapon
    }, "EmissiveMapAtten", minAtten, maxAtten, 2)
  end
end
function EnterLight(avatar)
  BrotherhoodArmor(avatar, "LIGHT")
end
function EnterDarkness(avatar)
  BrotherhoodArmor(avatar, "DARK")
end
function OnDeath(avatar)
  local armor = avatar:GetAttachment(armorType)
  if not IsNull(armor) then
  end
  if not IsNull(effectsType) then
    local attachedFX = avatar:GetAllAttachments(effectsType)
    if not IsNull(attachedFX) and #attachedFX ~= 0 then
      for i = 1, #attachedFX do
        if not IsNull(attachedFX[i]) then
          attachedFX[i]:Destroy()
        end
      end
    end
  end
end
