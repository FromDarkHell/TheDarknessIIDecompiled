setPost = Resource()
setFade = 0
reloadPost = false
function SetColorCorrection()
  local levelInfo = gRegion:GetLevelInfo()
  local initialPost = gRegion:GetLevelInfo().postProcess
  local playerAvatar = gRegion:GetPlayerAvatar()
  local gameCamera = playerAvatar:CameraControl()
  local postProcess = levelInfo.postProcess
  if reloadPost then
    gRegion:GetLevelInfo().postProcess = initialPost
  end
  gameCamera:PushColorCorrection(setPost, 0, -1, 0)
  postProcess.fade = setFade
end
