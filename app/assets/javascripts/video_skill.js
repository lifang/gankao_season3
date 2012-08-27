
function video_show(index){
    $(".mc_menu li").removeClass("hover");
    $($(".mc_menu li")[index]).addClass("hover");
    $(".video_more,.other_video h1").css("display","none");
    $(".video_more")[index].style.display="block";
    $(".other_video h1")[index].style.display="block";
    $(".xz_video").css("display","");
    $(".video_area embed").css("display","none");
}


function load_video(video_url){
    $(".xz_video").css("display","none");
    $(".video_area embed").css("display","");
    $(".video_area embed").attr("src",video_url);
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


function create_plan(category){
    var fs_xz=$(".fs_ul .hover").attr("index");
    var  max_score=$(".fs_span").html();
    if (parseInt(fs_xz)==0){
        var score=$(".fs_input").val();
        if (score==""||score.length==0||score=="目标分数"||isNaN(parseInt(score))){
            tishi_alert("请输入您的目标分数")
            return false;
        }
        if(parseInt(score)>max_score){
            tishi_alert("我们建议的最高分数是"+max_score+"分")
            return false
        }
        max_score=score
    }
    $.ajax({
        async:true,
        type: "POST",
        url: "/plans/create_plan.js",
        dataType: "script",
        data:{
            category_id : category,
            target_score : max_score
        }
    })
}

function toggle_show_score(e){
    $(".fs_xz").removeClass("hover");
    $(e).addClass("hover");
}

function update_info(){
    var email=$("#p_email").val();
    var myReg =new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    if (email==""||email.length==0){
        tishi_alert("请输入邮箱");
        return false;
    }
    if ( !myReg.test(email)) {
        tishi_alert("邮箱格式不正确，请核实！")
        return false;
    }
    $("#p_infos").submit();
}