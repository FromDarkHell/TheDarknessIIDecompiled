endMissionDelay = 0
local endMissionFadeDuration = 4
function EndMission()
  if endMissionDelay > 0 then
    Sleep(endMissionDelay)
  end
  gRegion:GetGameRules():EndGame(Engine.GameRules_GS_SUCCESS, endMissionFadeDuration)
end
