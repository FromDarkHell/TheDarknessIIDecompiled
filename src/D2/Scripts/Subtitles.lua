subtitleMovie = WeakResource()
textArray = {
  String()
}
delayArray = {0}
initialDelay = 0
function ShowSubtitle()
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local profileSettings = playerProfile:Settings()
  if profileSettings:Subtitles() then
    Sleep(initialDelay)
    local subMovie = gFlashMgr:FindMovie(subtitleMovie)
    for i = 1, #textArray do
      subMovie:Execute("DisplaySubTitle", textArray[i])
      if delayArray[i] ~= nil then
        Sleep(delayArray[i])
      end
    end
    subMovie:Execute("DisplaySubTitle", "")
  end
end
function ClearSubtitles()
  Sleep(initialDelay)
  local subMovie = gFlashMgr:FindMovie(subtitleMovie)
  subMovie:Execute("DisplaySubTitle", "")
end
