class SharedCode
{
   function SharedCode()
   {
   }
   static function fillText(thisClip, entryContent)
   {
      thisClip.TxtHolder.Txt.text = entryContent;
   }
   static function monitor(thisClip)
   {
      thisClip.onRollOver = function()
      {
         this.gotoAndPlay("MousedOver");
      };
      thisClip.onRollOut = function()
      {
         this.gotoAndPlay("NoFocus");
      };
      thisClip.onPress = function()
      {
         this.gotoAndPlay("Pressed");
      };
   }
   static function pressToGoTo(thisClip, destination)
   {
      thisClip.destinationFrame = destination;
      thisClip.onPress = function()
      {
         _root.gotoAndPlay(this.destinationFrame);
      };
   }
   static function setCheckboxState(checkbox, checked)
   {
      if(checked)
      {
         checkbox.gotoAndStop("Checked");
      }
      else
      {
         checkbox.gotoAndStop("Unchecked");
      }
   }
   static function setScrollExtendLevel(scrollbar, level)
   {
      level = Math.round(level);
      if(level > 100)
      {
         level = 100;
      }
      else if(level < 1)
      {
         level = 1;
      }
      scrollbar.Scrollbar.ScrubberAnim.gotoAndStop(level);
   }
   static function setScrollLevel(scrollbar, level)
   {
      level = Math.round(level);
      if(level > 100)
      {
         level = 100;
      }
      else if(level < 1)
      {
         level = 1;
      }
      scrollbar.Scrollbar.gotoAndStop(level);
   }
   static function adjustScrollWithMouse(luaFunctionName, scrollBar)
   {
      scrollBar.luaFunctionName = luaFunctionName;
      scrollBar.MinArrow.onPress = function()
      {
         getURL("FSCommand:" add this._parent.luaFunctionName,false);
      };
      scrollBar.MaxArrow.onPress = function()
      {
         getURL("FSCommand:" add this._parent.luaFunctionName,true);
      };
      scrollBar.Scrollbar.onPress = function()
      {
         if(this.ScrubberAnim._currentframe == 1)
         {
            if(this.ScrubberAnim._ymouse > this.ScrubberAnim._height)
            {
               getURL("FSCommand:" add this._parent.luaFunctionName,true);
            }
            else if(this.ScrubberAnim._ymouse < 0)
            {
               getURL("FSCommand:" add this._parent.luaFunctionName,false);
            }
         }
         else if(this.ScrubberAnim._ymouse > this.ScrubberAnim._height)
         {
            getURL("FSCommand:" add this._parent.luaFunctionName,true);
         }
         else if(this.ScrubberAnim._ymouse < this.ScrubberAnim._height - 10)
         {
            getURL("FSCommand:" add this._parent.luaFunctionName,false);
         }
      };
   }
   static function platformPicker(ThisClip)
   {
      if(_root.$platform == "WINDOWS")
      {
         ThisClip.gotoAndStop("PC");
      }
      else if(_root.$platform == "PS3")
      {
         ThisClip.gotoAndStop("PS3");
      }
      else
      {
         ThisClip.gotoAndStop("Xbox");
      }
   }
   static function manageBackBtn(ThisClip, ThisText)
   {
      SharedCode.platformPicker(ThisClip);
      ThisClip.BackLabel.TxtHolder.Txt.text = ThisText;
      if(_root.$platform == "WINDOWS")
      {
         SharedCode.monitor(ThisClip.BackLabel);
      }
   }
   static function manageSelectOKBtn(ThisClip, ThisText)
   {
      SharedCode.platformPicker(ThisClip);
      ThisClip.SelectOKLabel.TxtHolder.Txt.text = ThisText;
   }
   static function clamp(v, minValue, maxValue)
   {
      if(v < minValue)
      {
         return minValue;
      }
      if(v > maxValue)
      {
         return maxValue;
      }
      return v;
   }
}
