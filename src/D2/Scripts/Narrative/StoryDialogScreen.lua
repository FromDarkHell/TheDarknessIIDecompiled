storyText = String()
additionalScreenText = {
  String()
}
confirmMovie = Resource("/D2/Menus/StoryDialog.swf")
function StoryDialog(movie)
  local dialogsEnabled = gFlashMgr:GetConfigBool("Game.ShowStoryDialogs")
  if dialogsEnabled == true then
    while not IsNull(gClient:GetVignette()) do
      Sleep(0.25)
    end
    local movie = gFlashMgr:PushMovie(confirmMovie)
    movie:Execute("SetText", storyText)
    movie:SetFocus("OK")
    if additionalScreenText[1] ~= nil then
      for i = 1, #additionalScreenText do
        Sleep(0.05)
        local movie = gFlashMgr:PushMovie(confirmMovie)
        movie:Execute("SetText", additionalScreenText[i])
      end
    end
  else
    Broadcast("Story Dialog:")
    Broadcast(storyText)
    if additionalScreenText[1] ~= nil then
      for i = 1, #additionalScreenText do
        Sleep(2)
        Broadcast("Story Dialog:")
        Broadcast(additionalScreenText[i])
      end
    end
  end
end
