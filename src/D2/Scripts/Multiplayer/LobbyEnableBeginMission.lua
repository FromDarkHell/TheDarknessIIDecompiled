function Enable()
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) and gameRules:IsPlayingMPCampaign() then
    gameRules:SetCanBeginMission(true)
  end
end
