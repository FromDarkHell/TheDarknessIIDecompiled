avatarType = Type()
explosionBurst = Instance()
explosionSound = Instance()
explosionlight = Instance()
fireLightOne = Instance()
carMover = Instance()
tutDialog = Instance()
mobsterTime = 0
slomoCancelTime = 0
tutTime = 0
local KillAll = function()
  local avatars = gRegion:FindAll(avatarType, Vector(0, 0, 0), 0, INF)
  local player = gRegion:GetPlayerAvatar()
  if avatars ~= nil then
    for i = 1, #avatars do
      local avatar = avatars[i]
      if avatar ~= player then
        avatar:Damage(140)
      end
    end
  end
end
function Start(entity)
  local gameRules = gRegion:GetGameRules()
  local player = gRegion:GetPlayerAvatar()
  explosionSound:FirePort("Enable")
  player:SetHealth(20)
  gameRules:RequestSlomo()
  KillAll()
  carMover:FirePort("Start")
  if not IsNull(explosionBurst) then
    explosionBurst:FirePort("Enable")
  end
  Sleep(mobsterTime)
  Sleep(slomoCancelTime)
  gameRules:CancelSlomo()
  Sleep(tutTime)
  explosionSound:FirePort("Disable")
end
