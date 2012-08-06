
function video_show(index){
    $(".mc_menu li").removeClass("hover");
    $($(".mc_menu li")[index]).addClass("hover");
    $(".video_more,.other_video h1").css("display","none");
    $(".video_more")[index].style.display="block";
    $(".other_video h1")[index].style.display="block";
    $(".xz_video").html("↑<br>选择课程视频<br>开始学习");
}


function load_video(){
    $(".xz_video").html()
}

