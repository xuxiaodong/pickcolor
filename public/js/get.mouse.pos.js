jQuery(document).ready(function(){
   $("#special").click(function(e){
      $('#status').val(e.pageX +', '+ e.pageY);
   }); 
})
