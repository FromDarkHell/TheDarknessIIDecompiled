hugIdleCinematic = Instance()
fakeCreditScript = Instance()
killPlayerScript = Instance()
choiceMovie = WeakResource()
function Start()
  Sleep(0)
  _T.qteDecision = nil
  _T.qtePopupMode = "ENDINGDECISION"
  local cin = gRegion:GetPlayingCinematic()
  local movieInstance = gFlashMgr:PushMovie(choiceMovie)
  while true do
    if cin:IsPlaying() == true then
      if _T.qteDecision == "RIGHT" then
        killPlayerScript:FirePort("Execute")
        return
      elseif _T.qteDecision == "LEFT" then
        fakeCreditScript:FirePort("Execute")
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
