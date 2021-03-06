hellHead = Type()
npcAvatarType = Type()
npcDecoInstance = Instance()
startDelay = 0
afterFXDelay = 1
fadeTime = 3
effects = Type()
effectsBone = Symbol()
function meltAway()
  Sleep(startDelay)
  local avatar
  if IsNull(npcAvatarType) == false then
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
  else
    avatar = npcDecoInstance
  end
  if not IsNull(avatar) then
    avatar:Attach(hellHead, Symbol(), Vector(), Rotation())
    avatar:Attach(effects, effectsBone, Vector(), Rotation())
  end
  Sleep(afterFXDelay)
  local t = 0
  local val = 0
  while t < fadeTime do
    val = t / fadeTime
    avatar:SetMaterialParam("Cloak", val)
    Sleep(0)
    t = t + DeltaTime()
  end
end
