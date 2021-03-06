craneAvatarType = Type()
checkpointTrigger = Instance()
craneHealthThreshold = 450
function CheckpointAtCraneHealth()
  local craneAvatar = gRegion:FindNearest(craneAvatarType, Vector(), INF)
  local currentHealth = craneAvatar:GetHealth()
  while currentHealth > craneHealthThreshold do
    Sleep(0)
    currentHealth = craneAvatar:GetHealth()
  end
  if IsNull(_T.gEnemyCount) then
    _T.gEnemyCount = 0
  end
  while 0 < _T.gEnemyCount do
    Sleep(0)
  end
  checkpointTrigger:FirePort("Enable")
end
