headTypes = {
  Type()
}
armorType = Type()
headTintsDark = {
  Resource()
}
headTintsLight = {
  Resource()
}
tintColour = Color()
maxAtten = 6
minAtten = 0
armorCloakTime = 1
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
end
local CloakObject = function(deco, time)
  if IsNull(deco) == true then
    return
  end
  local startDissolve = deco:GetDissolve()
  time = time * (1 - startDissolve)
  local t = 0
  while time > t do
    if IsNull(deco) == true then
      return
    end
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
    deco[i]:SetMaterialParam("EmissiveTintColor", colour.red / 255, colour.green / 255, colour.blue / 255, colour.alpha / 255)
  end
end
local InterpolateTint = function(deco, colour, interTime)
  local startTint0 = {
    deco:GetMaterialParam("TintColor0", 2),
    deco:GetMaterialParam("TintColor0", 3),
    0,
    0
  }
  local startTint1 = {
    0,
    0,
    0,
    0
  }
  local startTint2 = {
    0,
    0,
    0,
    0
  }
  local startTint3 = {
    0,
    0,
    0,
    0
  }
  print("Val: " .. startTint0[1] .. " " .. startTint0[2])
end
function EnterDarkness(avatar)
  local head
  local agent = avatar:GetAgent()
  local armor = avatar:GetAttachment(armorType)
  for i = 1, #headTypes do
    head = avatar:GetAttachment(headTypes[i])
    if IsNull(head) == false then
      head:SetOverrideMaterial(0, headTintsDark[i])
      break
    end
  end
  SetTint({
    head,
    avatar,
    armor
  }, tintColour)
  if IsNull(armor) == false and not IsNull(agent) and agent:IsAlerted() == true then
    UncloakObject(armor)
  end
  InterpolateParam({
    head,
    avatar,
    armor
  }, "EmissiveMapAtten", minAtten, maxAtten, 2)
end
local function EnterLightLocal(avatar)
  local head
  local armor = avatar:GetAttachment(armorType)
  for i = 1, #headTypes do
    head = avatar:GetAttachment(headTypes[i])
    if IsNull(head) == false then
      head:SetOverrideMaterial(0, headTintsLight[i])
      break
    end
  end
  if not IsNull(head) then
    SetTint({
      head,
      avatar,
      armor
    }, tintColour)
  else
    SetTint({avatar, armor}, tintColour)
  end
  if IsNull(armor) == false then
    CloakObject(armor, armorCloakTime)
  end
  if not IsNull(head) then
    InterpolateParam({
      head,
      avatar,
      armor
    }, "EmissiveMapAtten", maxAtten, minAtten, 2)
  else
    InterpolateParam({avatar, armor}, "EmissiveMapAtten", maxAtten, minAtten, 2)
  end
end
function EnterLight(avatar)
  EnterLightLocal(avatar)
end
function OnDeath(entity)
  local armor = entity:GetAttachment(armorType)
  if not IsNull(armor) and armor:GetDissolve() < 1 then
    EnterLightLocal(entity)
  end
end
