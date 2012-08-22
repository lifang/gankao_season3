function updateUserInfo(){
    var info={};
    var username=$("#username").val();
    var school=$("#school").val();
    var email=$("#email").val();
    info["name"]=username;
    info["school"]=school;
    info["email"]=email;

    $.ajax({
        async:true,
        dataType:'json',
        data:{
            info:info
        },
        url:"/users/update_users",
        type:'post',
        success : function(data) {
            $("#name").html(info["name"]);
            $("#schoolName").html(info["school"]);
            alert(data.message);
        }
    });
    $(".x").click();
    return false;
}



//签到
function checkIn(){
    $.ajax({
        async:true,
        url:"/users/check_in?category="+category,
        type:'post',
        success:function(data){
            alert(data.message);
            $(".s_sun").html(data.num);
        //$(".checkIn_box").hide();
        }
    });
}

//分享
function send(web,message){
    $.ajax({
        async:true,
        dataType:'json',
        data:{
            message:message
        },
        url:"/users/send_message?category="+category+"&web="+web,
        type:'post' 
    });
}