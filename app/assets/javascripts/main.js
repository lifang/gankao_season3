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
    $("#pay_charge_vip").attr("target", "_blank");
    $('.pay_close').trigger('click');
    show_charge('.tishi_tab','.tishi_close');
    $(".tishi_close").bind('click',function(){
        over_pay();
    })
    $("#pay_charge_vip").attr("href", "/logins/alipay_exercise?category="+category+"&total_fee="+$("#pay_fee").html());
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
    if($("#invit_code").val()==""||$("#invit_code").val()==null||$.trim($("#invit_code").val()) == '请输入激活码'){
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
                tishi_alert("恭喜您成为高级会员。");
                window.setTimeout(function(){window.location.reload();}, 2000);
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
    $("#sunpay_a_tow").attr("target", "_blank");
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
    if ($(".guideBox").length > 0) {
        var doc_height = $(document).height();
        $('.guideMask').show();
        $('.guideMask').css('height',doc_height);
        $(".main").css('position', 'relative');
        var i= 1;
        $(".guide_next").bind("click",function(){
            $(this).parents(".guide0"+i).hide().next().show();
            i++;
        })
        $(".guide_out").bind("click",function(){
            $(this).parents(".guideBox").hide();
            $(".main").css('position', '');
            $('.guideMask').hide();
        })
    }
})

/*在线QQ*/
$(function(){
    $('.online_qq').hover(
        function () {
            $(this).animate( {
                right: '0'
            } , 500 );
        },
        function () {
            $(this).animate( {
                right: '-85px'
            } , 500 );
        });
})

//nav 单行滚动
function AutoScroll(obj){
    $(obj).animate({
        marginTop:"-42px"
    },500,function(){
        $(this).css({
            marginTop:"0px"
        }).find("span:first").appendTo(this);
    });
}
$(document).ready(function(){
    setInterval('AutoScroll(".scrollAD")',10000)
});

// right_ad自动轮换内容
$(document).ready(function(){
    var objStr = ".change ul li";
    $(objStr + ":not(:first)").css("display","none");
    setInterval(function(){
        if(
            $(objStr + ":last").is(":visible")){
            $(objStr + ":first").fadeIn("slow").addClass("in");
            $(objStr + ":last").hide()
        }
        else{
            $(objStr + ":visible").addClass("in");
            $(objStr + ".in").next().fadeIn("slow");
            $(objStr + ".in").hide().removeClass("in")
        }
    },4000) //每3秒钟切换
})

////右侧排行榜
//$(function(){
//    if ($(".progress_list").length > 0) {
//        var current_date = new Date();
//        var date = (new Date(2012, current_date.getMonth(), current_date.getDate()) - new Date(2012,8,13))/(3600*24*1000);
//        var arr = [235, 197, 324, 289, 377, 312, 263, 303, 202, 398];
//        var score_arr = [5, 5, 4, 4,  4, 4, 5, 4, 6, 3];
//        var s_start_mu = [18, 16, 14, 12, 10, 8, 6, 4, 2, 0];
//        var new_score = [];
//
//        for (var i=0; i<score_arr.length; i++) {
//            var current_score = score_arr[i] * (s_start_mu[i] + date - Math.floor(Math.random()*2));
//            new_score.push(current_score + arr[i]);
//        }
//        var tds = $(".progress_list table .find_tr td");
//        for (var j=0; j<10; j++) {
//            if (tds[(j+1)*3-1] != null || tds[(j+1)*3-1] != undefined) {
//                tds[(j+1)*3-1].innerHTML = new_score[j];
//            }
//        }
//    }
//});