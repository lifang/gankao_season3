
function video_show(index){
    $(".mc_menu li").removeClass("hover");
    $($(".mc_menu li")[index]).addClass("hover");
    $(".video_more,.other_video h1").css("display","none");
    $(".video_more")[index].style.display="block";
    $(".other_video h1")[index].style.display="block";
    $(".video_area").html('<div class="xz_video">↑<br/>选择讲师<br/>开始学习</div>');
}


function load_video(video_url){
    $(".video_area").html('<a  href='+ video_url+' style="display:block;width:520px;height:390px"  id="player"> </a>')
    flowplayer("player", "/assets/flowplayer/flowplayer.swf");
}

