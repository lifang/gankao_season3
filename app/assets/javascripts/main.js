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
    $('.pay_close').trigger('click');
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
                $(".tishi_close").bind('click',function(){
                    over_pay();
                })
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
    $(style).css('width',document.body.scrollWidth);
    $(style).show();
}

//显示考研弹出层
function show_kaoyan_frame() {
    show_mask('.mask');
    generate_flash_div("#inside_test_frame");
    $('.close').bind('click',function(){
        $('.mask').hide();
        $('#inside_test_frame').hide();
        window.location.reload();
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
    $("#sunpay_a_tow").attr("href","/logins/alipay_sun?category="+$("#sun_category").val()+"&total_fee="+sun_num)
}


function over_pay(){
    $.ajax({
        async:true,
        dataType:'json',
        type:'post',
        url:"/logins/over_pay",
        success : function(data) {
            window.location.reload();
        }
    });
}
//关注、 分享理由
function share_reason(){
    var reason=$(".gz_mh input:checked");
    if (reason.length==0){
        tishi_alert("请选择分享理由");
    }else{
        $.ajax({
            async:true,
            dataType:'json',
            type:'post',
            url:"/users/share_reasons",
            data :{
                category :$("#share_category").val()
            },
            success : function(data) {
                tishi_alert(data.message);
                setTimeout(function(){
                    window.location.reload();
                },1500);
            }
        });
    }
}

//答疑页面-----我要提问按钮
$(function(){
    $(".askQuestion_span").bind("click",function(){
        $(this).hide();
        $(".askQuestion_textarea").animate({
            height: "80px"
        }, 500);
        $(".askQuestion_btn").show();
        $(".askQuestion_up").show();
        $(".askQuestion_number").show();
    })
    $(".askQuestion_up").bind("click",function(){
        $(".askQuestion_span").show();
        $(".askQuestion_textarea").css("height","28px")
        $(".askQuestion_btn").hide();
        $(this).hide();
        $(".askQuestion_number").hide();
    })
})

//随机生成在线人数
$(function(){
    $(".index_btn #span1").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
    $(".index_btn #span2").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
    $(".index_btn #span3").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
    setInterval(function(){
        $(".index_btn #span1").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
        $(".index_btn #span2").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
        $(".index_btn #span3").html("在线"+ (Math.floor(Math.random()*1000)+1000) + "人");
    }, 3600000);
})

//复习计划页面功能介绍
$(function(){
	var doc_height = $(document).height();
	//var doc_width = $(document).width();
	var win_height = $(window).height();
	var win_width = $(window).width();

    $('.guideMask').css('height',doc_height);

	var i= 1;
	$(".guide_next").bind("click",function(){
		    //alert($("this").parents(".guide01"));
			$(this).parents(".guide0"+i).hide().next().show();
			i++;
	})
	$(".guide_out").bind("click",function(){
			$(this).parents(".guideBox").hide();
			$('.guideMask').hide();
	})

})