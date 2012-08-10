$(document).ready(function(){
   
    $(".pl_img #unlock").click(function(){
        generate_flash_div("plan_tab");
    })

    function generate_flash_div(style) {
        var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
        var win_height = document.documentElement.clientHeight;//jQuery(document).height();
        var win_width = $(window).width();
        var z_layer_height = $("."+style).height();
        var z_layer_width = $("."+style).width();
        $("."+style).css('top',(win_height-z_layer_height)/2 + scolltop);
        $("."+style).css('left',(win_width-z_layer_width)/2);
        $("."+style).show();
    }
})