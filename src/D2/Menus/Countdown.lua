local StartState_Started = 4
function Initialize(movie)
end
function Update(movie)
  local gameRules = gRegion:GetGameRules()
  local timeLeft = gameRules:GetGameStartTimeLeft()
  local startState = gameRules:GetStartState()
  if startState < StartState_Started then
    movie:SetLocalized("Message.text", "/D2/Language/Menu/WaitingForPlayers_Msg")
  elseif 0 < timeLeft then
    local strFmt = movie:GetLocalized("/D2/Language/Menu/Countdown_TimeLeft")
    movie:SetLocalized("Message.text", string.format(strFmt, timeLeft))
  else
    movie:Close()
  end
end
