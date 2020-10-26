successCinematic = Instance()
failCinematic = Instance()
failThreshold = 3
function ParseQTESuccessState()
  local playerAvatar = gRegion:GetPlayerAvatar()
  if _T.failCount == nil then
    _T.failCount = 0
  end
  if _T.qteSuccessState == true then
    successCinematic:FirePort("StartPlaying")
  elseif _T.qteSuccessState == false then
    if _T.popupMode == "BUTTONPRESS" then
      failCinematic:FirePort("StartPlaying")
    elseif _T.failCount >= failThreshold then
    end
  else
    print("RUHROH")
  end
end
function ResetFailCount()
  _T.failCount = 0
end
