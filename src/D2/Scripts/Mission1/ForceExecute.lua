function ForceExecute()
  Sleep(0.1)
  local player = gRegion:GetPlayerAvatar()
  player:SetCarriedAvatarExecutionRequired(true)
end
