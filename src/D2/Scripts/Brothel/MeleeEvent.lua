healthThreshold = 20
swingAnim = Resource()
deathAnim = Resource()
deathAnimTime = 1
avatarType = Type()
ragdollFX = Type()
meleeImpactSound = Resource()
deathDistance = 1
destination = Instance()
function Start()
  local avatar = gRegion:FindNearest(avatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  local setHealth = 5
  avatar:SetHealth(setHealth)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local postProcess = gRegion:GetLevelInfo().postProcess
  playerAvatar:SetHealth(setHealth)
  avatar:PlayAnimation(swingAnim, false, true, false)
  while playerAvatar:GetHealth() > 0 do
    Sleep(0)
  end
  Sleep(0.5)
  postProcess.fade = 2
end
