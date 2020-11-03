class SMListItem extends MovieClip
{
   var index = -1;
   var prev = null;
   var next = null;
   var data = null;
   var callback = null;
   var callbackTarget = null;
   var onMouseOver = null;
   var onMouseOut = null;
   var type = SMListItem.TYPE_STANDARD;
   var _enabled = true;
   static var TYPE_STANDARD = 1;
   static var TYPE_TOGGLE = 2;
   static var TYPE_SEPARATOR = 3;
   function SMListItem()
   {
      super();
      this.onPress = this.press;
      this.onRollOver = this.rollOver;
      this.onRollOut = this.rollOut;
      this.onReleaseOutside = this.releaseOutside;
   }
   function setType(t)
   {
      switch(t)
      {
         case SMListItem.TYPE_STANDARD:
         default:
            this.type = SMListItem.TYPE_STANDARD;
            this.gotoAndStop("DEFAULT");
            break;
         case SMListItem.TYPE_TOGGLE:
            this.type = SMListItem.TYPE_TOGGLE;
            this.gotoAndStop("TOGGLE");
            if(this.data == true)
            {
               this.checkBox.gotoAndStop("ON");
            }
            else
            {
               this.checkBox.gotoAndStop("OFF");
            }
            break;
         case SMListItem.TYPE_SEPARATOR:
            this.gotoAndStop("SEPARATOR");
      }
   }
   function setText(text)
   {
      this.label.text = text;
   }
   function setEnabled(value)
   {
      if(value == this._enabled)
      {
         return undefined;
      }
      this._enabled = value;
      if(!this._enabled)
      {
         delete this.onPress;
         delete this.onRollOver;
         delete this.onRollOut;
      }
      else
      {
         this.onPress = this.press;
         this.onRollOver = this.rollOver;
         this.onRollOut = this.rollOut;
      }
   }
   function press()
   {
      if(this.type == SMListItem.TYPE_TOGGLE)
      {
         if(this.data == true)
         {
            this.data = false;
            this.checkBox.gotoAndStop("OFF");
         }
         else
         {
            this.data = true;
            this.checkBox.gotoAndStop("ON");
         }
      }
      else if(this.type == SMListItem.TYPE_SEPARATOR)
      {
         return undefined;
      }
      this.master.itemSelect(this);
      if(this.callback)
      {
         this.callback.call(this.callbackTarget,this);
      }
   }
   function rollOver()
   {
      this.master.itemFocus(this);
      if(this.onMouseOver)
      {
         this.onMouseOver.call();
      }
   }
   function rollOut()
   {
      this.master.itemLoseFocus(this);
      if(this.onMouseOut)
      {
         this.onMouseOut.call();
      }
   }
   function releaseOutside()
   {
      this.master.itemLoseFocus(this);
      if(this.onMouseOut)
      {
         this.onMouseOut.call();
      }
   }
}
