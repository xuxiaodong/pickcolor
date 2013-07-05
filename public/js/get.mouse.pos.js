jQuery(document).ready(function(){
   $("#special").click(function(e){
       var x = e.pageX - this.offsetLeft;
       var y = e.pageY - this.offsetTop;
      $('#status').val(x +', '+ y);
   }); 
})
