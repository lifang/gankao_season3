// JavaScript Document

//顶部人物信息弹出层 u_tab_div
function infoTab(i_tab,i_box,x){
    $(i_tab).click(function(e){
        $(".u_tab_div").hide();
        $(i_box).show();
        $(i_box).css({
            'top':(e.pageY+10)+'px',
            'left':(e.pageX-50)+'px'
        });
    });
			
    $(x).click(function(){
        $(i_box).hide();
    })
}

//小太阳提示
$(function(){
    $(".s_sun_mess").fadeIn(1000);
    window.setTimeout(function sunMess(){
        $(".s_sun_mess").fadeOut("slow");
    },4000);

    $(".s_sun").hover(function(){
        $(".s_sun_mess").css("display","block");
    },function(){
        $(".s_sun_mess").css("display","none");
    }
    )
})

$(document).ready(function(){
    infoTab('.u_set','#u_set_div','.x');//设置弹出框
    infoTab('.u_subject','#u_subject_div','.x');//科目弹出框
})

//人物信息默认值
$(function(){
    $('.u_tab_div input').focus(function(){
        var thisVal = $(this).val();
        if(thisVal == this.defaultValue){
            $(this).val('');
        }
    })
    $('.u_tab_div input').blur(function(){
        var thisVal = $(this).val();
        if(thisVal == ''){
            $(this).val(this.defaultValue);
        }
    })
})

//tooltip提示
$(function(){
    var x = 0;
    var y = 20;
    $(".tooltip").mouseover(function(e){
        this.myTitle=this.title;
        this.title="";
        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";
		
        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){
        this.title = this.myTitle;
        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})

//知识库
$(function(){
    $('.article_h').bind('click',function(){
        $(this).next().addClass('open').parent().siblings().children('.article_p').removeClass('open');
        $('.open').slideDown("slow").parent().siblings().children('.article_p').slideUp("slow");
    })
})



function check_vip(category){
    $('.close').trigger('click');
    $.ajax({
        async:true,
        dataType:'json',
        type:'post',
        url:"/logins/check_vip",
        data:{
            category:category
        },
        success : function(data) {
            if(data.vip){
                show_charge('.tishi_tab','.tishi_close');
                window.open("/logins/alipay_exercise?category="+category+"&total_fee="+$("#pay_fee").html(),
                    '_blank','height=750,width=1000,left=200,top=50');
            }else{
                var str = (data.time == null || data.time == "") ? "" : "，截止日期是"+data.time;
                tishi_alert("您已是vip用户"+str);
            }
        }
    });
}

//带遮罩层的弹出层
function show_charge(outer_div,close_btn){
    show_mask('.mask');
    generate_flash_div(outer_div);
    $(close_btn).bind('click',function(){
        $(outer_div).css('display','none');
        $('.mask').css('display','none');
    })
}//outer_div 遮罩层显示的部分 close_btn 关闭按钮


function accredit(category){
    if($("#invit_code").val()==""||$("#invit_code").val()==null){
        tishi_alert("请输入邀请码");
        return false;
    }
    $.ajax({
        async:true,
        dataType:'json',
        type:'post',
        data:{
            info:$("#invit_code").val(),
            category:category
        },
        url:"/logins/accredit_check",
        success : function(data) {
            $("#invit_code").val("");
            if (data.message=="升级成功"){
                window.location.reload();
            } else {
                tishi_alert(data.message);
            }
        }
    });
    return false;
}

//弹出复习的层
function show_mask(style) {
    $(style).css('height',document.body.scrollHeight);
    $(style).show();
}

//显示考研弹出层
function show_kaoyan_frame() {
    show_mask('.mask');
    generate_flash_div("#inside_test_frame");
    $('.close').bind('click',function(){
        $('.mask').hide();
        $('#inside_test_frame').hide();
        return false;
    })
}

//小太阳充值验证
function sun_charge(){
    var sun_num=$("#sun_fee").val();
    if (sun_num.match(/^[0-9]+$/)==null || parseInt(sun_num)<=0){
        tishi_alert("请输入整数");
        return false;
    }
     $('#close_sun').trigger('click');
      show_charge('#tab_sun','#tab_close');
    window.open("/logins/alipay_sun?category="+$("#sun_category").val()+"&total_fee="+sun_num,'_blank','height=750,width=1000,left=200,top=50');
}