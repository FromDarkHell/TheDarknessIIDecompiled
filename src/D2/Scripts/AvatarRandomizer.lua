MeshTable = {
  Resource()
}
TintTable = {
  Resource()
}
HeadTable = {
  Type()
}
DecapHeadTable = {
  Resource()
}
Glasses = {
  Type()
}
Masks = {
  Type()
}
Hats = {
  Type()
}
glassesPositionalOffset = Vector(-0.07, -0.01, 0)
glassesRotationalOffset = Rotation(-90, 70, 0)
maskPositionalOffset = Vector(1.66, -0.6, 0)
maskRotationalOffset = Rotation(-90, 70, 0)
hatsPositionalOffset = Vector(1.66, -0.6, 0)
hatsRotationalOffset = Rotation(-90, 70, 0)
local Accessorize = function(avatar, headAttachment)
  local headBone = Symbol("GAME_C1_HEAD1")
  local hipBone = Symbol("GAME_C1_HIP1")
  local rootBone = Symbol("GAME_C1_ROOT")
  if RandomInt(0, 1) == 1 and #Glasses ~= 0 then
    local glass = RandomInt(1, #Glasses)
    local po = glassesPositionalOffset
    local ro = glassesRotationalOffset
    avatar:Attach(Glasses[glass], headBone, po, ro)
  end
  if RandomInt(0, 1) == 1 and #Masks ~= 0 then
    local mask = RandomInt(1, #Masks)
    local po = maskPositionalOffset
    local ro = maskRotationalOffset
    avatar:Attach(Masks[mask], headBone, po, ro)
  end
  if RandomInt(0, 1) == 1 and #Hats ~= 0 then
    local hat = RandomInt(1, #Hats)
    local po = hatsPositionalOffset
    local ro = hatsRotationalOffset
    avatar:Attach(Hats[hat], headBone, po, ro)
  end
end
function RandomizeAvatar(avatar)
  local mesh = RandomInt(1, #MeshTable)
  local tint = RandomInt(1, #TintTable)
  local head = RandomInt(1, #HeadTable)
  local headAttachment
  if #MeshTable ~= 0 then
    avatar:SetMesh(MeshTable[mesh], true, true)
  end
  if #TintTable ~= 0 and RandomInt(1, #TintTable) ~= 0 then
    avatar:SetOverrideMaterial(0, TintTable[tint])
  end
  if #HeadTable ~= 0 then
    headAttachment = avatar:Attach(HeadTable[head], Symbol())
    if head <= #DecapHeadTable then
      avatar:SetSeverMesh(Engine.HEAD, DecapHeadTable[head])
    end
  end
  Accessorize(avatar, headAttachment)
end
