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
            if (data.message != "你今天已经签过到了哦~~~") {
                $(".addOne").fadeIn("slow").animate({top:'0px'},800).fadeOut("slow");
            }
            tishi_alert(data.message);
            $(".s_sun").html(data.num);
            $("#checkIn_days").html(data.days);
        }
    });
}

//保过协议用户信息验证
function check_xieyi() {
    if ($.trim($("#charge_name").val()) == "" || $("#charge_name").val().length > 20) {
        tishi_alert("请正确填写您的姓名，且长度不能超过20个字符。");
        return false;
    }
    if ($.trim($("#charge_card").val()) == "" || $("#charge_card").val().length > 20) {
        tishi_alert("请正确填写您的身份证，且长度不能超过20个字符。");
        return false;
    }
    if ($.trim($("#alipay_num").val()) == "" || $("#alipay_num").val().length > 200) {
        tishi_alert("请正确填写您的支付宝账号，以方便我们汇款，长度不能超过200个字符。");
        return false;
    }
    if ($.trim($("#charge_name").val()) != $.trim($("#charge_name1").val())) {
        tishi_alert("'甲方（姓名）'与考生名称不一致，请填写一致");
        return false;
    }
    $.ajax({
        async:true,
        url:"/users/xieyi",
        type:'post',
        data: {
            charge_name : $("#charge_name").val(),
            charge_card : $("#charge_card").val(),
            alipay_num : $("#alipay_num").val(),
            pay_category : $("#pay_category").val()
        },
        success:function(data){
            tishi_alert("赶考网在线备考保过协议签订成功，确认支付后下载保过协议");
            $("#agreement_link").attr("href", data.agreement_url);
            $("#agreement_link").attr("target", "_blank");
        }
    });
}
