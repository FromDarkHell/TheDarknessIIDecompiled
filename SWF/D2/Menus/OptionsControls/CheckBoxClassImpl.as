class CheckBoxClassImpl
{
   var mThisMC = null;
   var mID = "";
   var mIsEnabled = true;
   var mIsChecked = false;
   var mSelectedCallback = "CheckBoxSelected";
   var mUnselectedCallback = "CheckBoxUnselected";
   var mPressedCallback = "CheckBoxPressed";
   var mSelectedColor = 16711680;
   var mUnselectedColor = 16777215;
   function CheckBoxClassImpl(mc)
   {
      this.mThisMC = mc;
      this.mID = this.mThisMC._name;
      this.mThisMC.CheckBoxClass = this;
      this.mThisMC.noMenuSelection = true;
      this.mThisMC.onPress = function()
      {
         this.CheckBoxClass.SetChecked(!this.CheckBoxClass.mIsChecked);
         this.CheckBoxClass.Pressed();
      };
      this.mThisMC.onRollOver = function()
      {
         this.CheckBoxClass.Selected();
      };
      this.mThisMC.onRollOut = function()
      {
         this.CheckBoxClass.Unselected();
      };
   }
   function SetEnabled(isEnabled)
   {
      this.mIsEnabled = isEnabled;
      this.mThisMC.enabled = isEnabled;
   }
   function SetID(newID)
   {
      this.mID = newID;
   }
   function SetChecked(checked)
   {
      if(this.mThisMC.Check != undefined)
      {
         if(checked)
         {
            this.mThisMC.Check.gotoAndPlay("Checked");
         }
         else
         {
            this.mThisMC.Check.gotoAndPlay("Unchecked");
         }
      }
      this.mIsChecked = checked;
   }
   function SetCallbackPressed(c)
   {
      this.mPressedCallback = c;
   }
   function SetCallbackSelected(c)
   {
      this.mSelectedCallback = c;
   }
   function SetCallbackUnselected(c)
   {
      this.mUnselectedCallback = c;
   }
   function Selected()
   {
      var _loc2_ = this.mID;
      if(this.mSelectedCallback != "")
      {
         getURL("FSCommand:" add this.mSelectedCallback,_loc2_);
      }
      this.mThisMC._color = this.mSelectedColor;
   }
   function Unselected()
   {
      var _loc2_ = this.mID;
      if(this.mUnselectedCallback != "")
      {
         getURL("FSCommand:" add this.mUnselectedCallback,_loc2_);
      }
      this.mThisMC._color = this.mUnselectedColor;
   }
   function Pressed(mc)
   {
      var _loc2_ = this.mID;
      if(this.mPressedCallback != "")
      {
         getURL("FSCommand:" add this.mPressedCallback,_loc2_);
      }
      this.mThisMC._color = this.mSelectedColor;
   }
}
