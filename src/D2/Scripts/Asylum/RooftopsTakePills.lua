pillsCinematic = Instance()
jumpCinematic = Instance()
startDancingScript = Instance()
choiceMovie = Resource()
function Start()
  Sleep(0)
  _T.qteDecision = nil
  _T.qtePopupMode = "ROOFDECISION"
  local cin = gRegion:GetPlayingCinematic()
  local movieInstance = gFlashMgr:PushMovie(choiceMovie)
  while true do
    if cin:IsPlaying() == true then
      if _T.qteDecision == "RIGHT" then
        jumpCinematic:FirePort("StartPlaying")
        return
      elseif _T.qteDecision == "LEFT" then
        startDancingScript:FirePort("Execute")
        return
      end
      Sleep(0)
    else
      if _T.qteDecision == nil then
      end
      Sleep(0)
    end
  end
end
