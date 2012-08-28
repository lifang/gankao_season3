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
function checkIn(category){
    $.ajax({
        async:true,
        url:"/users/check_in?category="+category,
        type:'post',
        success:function(data){
            tishi_alert(data.message);
            $(".s_sun").html(data.num);
            $("#checkIn_days").html(data.days);
        }
    });
}

//关注、 分享理由
$(function(){
    $("#btn_ok").click(function(){
        var web=$("input[value=true]").parent().siblings("p").html();
        if (web){
            //获取理由信息
            var message=$("select#share_reson").val();
            if (message=="请选择")
            {
                alert("请选择分享理由!!");
            }
            else
            {
                if (web=="renren")
                {
                    window.open('/users/kaoyan_share?web=renren&message='+message, '_blank', 'height=500,width=600,left=300,top=100');
                }
                else if(web=="sina"){
                    window.open('/users/kaoyan_share?web=sina&message='+message, '_blank', 'height=500,width=600,left=300,top=150');
                }
                else{
                    window.open('/users/kaoyan_share?web=qq&message='+message, '_blank', 'height=480,width=510,left=300,top=150');
                }
            }
        }
        else{
            alert("请选择关注或分享的类型!!!");
        }
    });
});
