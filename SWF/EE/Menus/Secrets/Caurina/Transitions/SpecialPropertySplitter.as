class Caurina.Transitions.SpecialPropertySplitter
{
   function SpecialPropertySplitter(p_splitFunction, p_parameters)
   {
      this.splitValues = p_splitFunction;
      this.parameters = p_parameters;
   }
   function splitValues(p_value, p_parameters)
   {
      return [];
   }
   function toString()
   {
      var _loc2_ = "";
      _loc2_ = _loc2_ + "[SpecialPropertySplitter ";
      _loc2_ = _loc2_ + ("splitValues:" + this.splitValues.toString());
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("parameters:" + this.parameters.toString());
      _loc2_ = _loc2_ + "]";
      return _loc2_;
   }
}
