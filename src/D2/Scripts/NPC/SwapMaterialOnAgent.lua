avatarType = Type()
material = Resource()
slot = 1
function Start()
  local avatar = gRegion:FindNearest(avatarType, Vector(), INF)
  if IsNull(avatar) == false then
    avatar:SetOverrideMaterial(slot, material)
  end
end
