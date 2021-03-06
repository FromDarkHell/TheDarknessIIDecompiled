module((...), package.seeall)
function CreateCalloutBar(pMovie, pInterpolator, pClipName)
  pMovie:SetVariable(pClipName .. "._alpha", 0)
  return {
    movie = pMovie,
    interpolator = pInterpolator,
    clipName = pClipName,
    currentCallouts = {},
    initialX = tonumber(pMovie:GetVariable(pClipName .. ".callout1._x")),
    transitionInTime = 0.13,
    transitionInDelay = 0.06,
    maxCallouts = 4,
    calloutWidth = tonumber(pMovie:GetVariable(pClipName .. "._width")),
    prefix = "CalloutBar(" .. pClipName .. ")::",
    SetCallouts = function(this, callouts)
      if IsNull(callouts) then
        callouts = {}
      end
      local clip = this.movie:GetVariable(this.clipName)
      if IsNull(clip) or clip == "undefined" then
        return
      end
      local calloutsChanged = false
      if IsNull(this.currentCallouts) then
        calloutsChanged = true
      elseif #callouts ~= #this.currentCallouts then
        calloutsChanged = true
      else
        for c = 1, #callouts do
          if callouts[c].Label ~= this.currentCallouts[c].Label then
            calloutsChanged = true
            break
          end
        end
      end
      if not calloutsChanged then
        return
      end
      this.currentCallouts = callouts
      for i = 1, this.maxCallouts do
        this.movie:SetVariable(this.clipName .. ".highlight" .. i .. ".btn._visible", false)
        local callback
        if i == this.maxCallouts then
          function callback()
            this:ApplyCallouts()
          end
        end
        this.interpolator:Interpolate(this.movie, this.clipName .. ".callout" .. i, this.interpolator.EASE_LINEAR, {"_alpha"}, {0}, 0.1, 0, callback)
      end
    end,
    ApplyCallouts = function(this)
      local clip = this.movie:GetVariable(this.clipName)
      if IsNull(clip) or clip == "undefined" then
        return
      end
      local numCallouts = 0
      local clipName, highlight, callback, label
      for i = 1, this.maxCallouts do
        clipName = this.clipName .. ".callout" .. i
        highlight = this.clipName .. ".highlight" .. i
        local newAlpha = 100
        if IsNull(this.currentCallouts[i]) then
          newAlpha = 0
        end
        this.movie:SetVariable(clipName .. "._alpha", newAlpha)
        callback = ""
        if not IsNull(this.currentCallouts[i]) then
          label = this.currentCallouts[i].Label
          callback = this.currentCallouts[i].Callback
          this.movie:SetVariable(highlight .. ".callback", callback)
          this.movie:SetLocalized(clipName .. ".text", label)
          this.movie:SetVariable(highlight .. ".btn._xscale", tonumber(this.movie:GetVariable(clipName .. ".textWidth")) + 10)
          this.movie:SetVariable(highlight .. ".btn._visible", callback ~= "")
          numCallouts = numCallouts + 1
        end
      end
      for i = 1, numCallouts do
        clipName = this.clipName .. ".callout" .. i
        highlight = this.clipName .. ".highlight" .. i
        this.movie:SetVariable(clipName .. "._alpha", 0)
        this.movie:SetVariable(clipName .. "._x", this.initialX - 20)
        this.movie:SetVariable(highlight .. "._alpha", 100)
        this.movie:SetVariable(highlight .. "._x", this.initialX + tonumber(this.movie:GetVariable(clipName .. "._width")))
        this.interpolator:Interpolate(this.movie, clipName, this.interpolator.EASE_LINEAR, {"_alpha", "_x"}, {
          100,
          this.initialX
        }, this.transitionInTime)
      end
      this.movie:SetVariable(this.clipName .. "._alpha", 100)
    end
  }
end
