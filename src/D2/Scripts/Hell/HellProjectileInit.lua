target = Instance()
target2 = Instance()
launchTime = 0
local shootCount = 0
local SetProjectileList = function(objectSpawner)
end
function TargetPlayer(objectSpawner)
  local player = gRegion:GetPlayerAvatar()
  objectSpawner:SetTarget(player, Vector())
end
function TargetObject(objectSpawner)
  objectSpawner:PushTarget(target, launchTime)
end
function SpamTarget(objectSpawner)
  objectSpawner:PushTarget(target, 0.1)
end
