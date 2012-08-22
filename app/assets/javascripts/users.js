function updateUserInfo(){
    var info={};
    var username=$("#username").val();
    var school=$("#school").val();
    var email=$("#email").val();
    
    var myReg =new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    if ( !myReg.test(email)) {
        tishi_alert("邮件格式输入错误example:xxxxx@sina.com");
        return false;
    }
    
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
            tishi_alert(data.message);
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
            tishi_alert(data.message);
            $(".s_sun").html(data.num);
            //$(".checkIn_box").hide();
        }
    });
}
 