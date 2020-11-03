class Label
{
   function Label()
   {
   }
   static function SetText(mc, s)
   {
      mc.mText = s;
      mc.Txt.text = mc.mText;
      mc.Txt.setTextFormat(mc.mTextFormat);
   }
   static function SetVariable(mc, s)
   {
      mc.mText = s;
      mc.mVariable = s;
      mc.Txt.variable = s;
      mc.Txt.setTextFormat(mc.mTextFormat);
   }
   static function GetText(mc)
   {
      return mc.mText;
   }
   static function GetColor(mc)
   {
      return mc.mColor;
   }
   static function SetColor(mc, c)
   {
      mc.mColor = c;
      mc.mTextFormat.color = mc.mColor;
      mc.Txt.setTextFormat(mc.mTextFormat);
   }
   static function GetAlignment(mc)
   {
      return mc.mAlignment;
   }
   static function SetAlignment(mc, s)
   {
      mc.mAlignment = s;
      mc.mTextFormat.align = mc.mAlignment;
      mc.Txt.setTextFormat(mc.mTextFormat);
   }
   static function IsVisible(mc)
   {
      return mc.mVisible;
   }
   static function SetVisible(mc, b)
   {
      mc.mVisible = b;
      mc._visible = mc.mVisible;
   }
}
