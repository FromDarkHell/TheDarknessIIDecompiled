initialDelay = 0
hugCinematic = Instance()
angelusCinematic = Instance()
qteMovie = WeakResource()
local letJennyGoMessage = "/D2/Language/Menu/QuickTimePopup_LeftMessage"
function Start()
  Sleep(initialDelay)
  _T.qteDecision = nil
  _T.qtePopupMode = "BUTTONPRESS"
  local cin = gRegion:GetPlayingCinematic()
  local movieInstance = gFlashMgr:GotoMovie(qteMovie)
  while true do
    if cin:IsPlaying() == true then
      Sleep(0)
      if _T.qteDecision == true then
        angelusCinematic:FirePort("StartPlaying")
        return
      end
    else
      Sleep(0)
    end
  end
end
