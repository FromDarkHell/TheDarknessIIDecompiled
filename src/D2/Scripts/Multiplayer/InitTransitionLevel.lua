initLevelScriptTrigger = Instance()
function Initialize()
  if not IsNull(initLevelScriptTrigger) then
    initLevelScriptTrigger:RunScripts()
  else
    print("NULL script trigger")
  end
end
