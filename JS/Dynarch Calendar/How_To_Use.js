<img src="#IMAGE_PREFIX#FNDICLDR.gif" id="P3_CALENDAR_TRIGER_1" alt="Calendar Trigger" style="vertical-align: bottom; cursor: pointer;" />
<script type="text/javascript">
$(document).ready(function() {

   var jun98Array = [];
   var maxDate = 	Calendar.intToDate($("#PXX_CAL_MAX").val());
   var minDate = 	Calendar.intToDate($("#PXX_CAL_MIN").val());
   
   for (var i = 0; i < 30; i++) {
    if (i < 9){
    jun98Array[i] = 1998060 + [i + 1];
    }else{
    jun98Array[i] = 199806 + [i + 1];
    }
   }
   
   if ($.browser.mozilla()){
    for (var i = 0, len=jun98Array.length; i<len; ++i) {
      if (jun98Array[i] == $("#P3_CAL_LESS_12YERS_MAX").val()){
        maxDate = Calendar.intToDate(19980531);
      }
    }
   }
   
var CAL_1 = Calendar.setup({
    inputField : "P3_DATE_OF_BIRTH",
    dateFormat : "%d-%b-%Y",
    trigger    : "P3_CALENDAR_TRIGER_1",
    bottomBar  : false,
    min        : minDate,
    max        : maxDate,
    onSelect   : function() {this.hide(); }
});

});
</script>