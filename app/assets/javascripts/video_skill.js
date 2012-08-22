
function video_show(index){
    $(".mc_menu li").removeClass("hover");
    $($(".mc_menu li")[index]).addClass("hover");
    $(".video_more,.other_video h1").css("display","none");
    $(".video_more")[index].style.display="block";
    $(".other_video h1")[index].style.display="block";
    $(".video_area").html('<div class="xz_video">↑<br/>选择讲师<br/>开始学习</div>');
}


function load_video(video_url){
    $(".video_area").html('<div id="mediaspace"> </div>')
    jwplayer('mediaspace').setup({
        'flashplayer': '/assets/jwplayer/player.swf',
        'file': video_url,
        'controlbar': 'bottom',
        'width': '520',
        'height': '390',
        'screencolor': '#000000',
        'image': "/skill.png"
    });
}

function deliver_blog(){
    var title=$("#title").val();
    var con=$("#text_con").val();
    if (title==""||title.length==0||title=="请在这里输入标题"){
        alert("请输入技巧标题");
        return false;
    }
    if (con==""||con.length<15){
        alert("技巧内容不能少于15个字");
        return false;
    }
    $("#blog").submit();
}

function create_blog(){
    $("#my_blog").css("display","none");
    $(".blog_content").css("display","none");
    $("#new_blog").css("display","");
    var types=$("#blog_types").val();
    if (parseInt(types)>4 || parseInt(types)<1){
        $("#blog_types").val(1);
    }
}

function show_blog(index){
    window.location.href="/skills?category_id="+$("#category_id").val() +"&con_t="+index;
}

function like_one(id){
    var like_num=parseInt($(".like em").html())+1;
    $(".like em").html(like_num);
    $(".like").attr("onclick",'');
    $.ajax({
        async:true,
        type: "POST",
        url: "/skills/like_blog.json",
        data:{
            blog_id : id,
            like_num :like_num
        },
        dataType: "json",
        success : function(data) {

        }
    })
}

function search_blog(){
    var search_con = $("#search_con").val();
    if (search_con==""&&search_con.length==0){
        tishi_alert("请输入您查询的关键字");
        return false;
    }
    $("#search_blog").submit();
}