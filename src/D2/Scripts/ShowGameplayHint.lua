hudMovie = WeakResource()
messageText = Symbol()
duration = 0
delay = 0
function ShowGameplayHint()
  Sleep(delay)
  local hudInstance = gFlashMgr:FindMovie(hudMovie)
  if not IsNull(hudInstance) then
    local args = string.format("%s,%f", tostring(messageText), duration)
    hudInstance:Execute("ShowAdaptiveTrainingHint", args)
  end
end
