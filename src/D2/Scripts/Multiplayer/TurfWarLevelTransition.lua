fadeDuration = 0
function GotoNextLevel()
  local gameRules = gRegion:GetGameRules()
  if not IsNull(gameRules) then
    gameRules:EndGame(Engine.GameRules_GS_SUCCESS, fadeDuration)
  end
end
