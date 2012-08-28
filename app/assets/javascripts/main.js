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


//video图标左右点击移动
$(function(){
    var page = 1;
    var i = 5;
    $('div.video_next').click(function(){
        var $parent = $(this).parents('div.video_more');
        var $video_show = $parent.find('.video_ul')
        var $videoImg = $parent.find('.video_box');
        var video_width = $videoImg.width();
        var len = $video_show.find('li').length;
        var page_count = Math.ceil(len/i);
		
        if(!$video_show.is(':animated')){
            $parent.find('div.video_prev').css('visibility','visible');
            if(page == page_count){
                $(this).css('visibility','hidden');
            }else{
                $video_show.animate({
                    marginLeft:'-='+video_width
                },'slow');
                page++;
                if(page == page_count){
                    $(this).css('visibility','hidden');
                }
            }
        }
    })
	
	
    $('div.video_prev').click(function(){
        var $parent = $(this).parents('div.video_more');
        var $video_show = $parent.find('.video_ul')
        var $videoImg = $parent.find('.video_box');
        var video_width = $videoImg.width();
        var len = $video_show.find('li').length;
        var page_count = Math.ceil(len/i);
		
        if(!$video_show.is(':animated')){
            $parent.find('div.video_next').css('visibility','visible');
            if(page == 1){
                $(this).css('visibility','hidden');
            }else{
                $video_show.animate({
                    marginLeft:'+='+video_width
                },'slow');
                page--;
                if(page == 1){
                    $(this).css('visibility','hidden');

                }
				
            }
        }
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
    
    //    var doc_height = $(document).height();
    //    var doc_width = $(document).width();
    //    var z_layer_height = $(outer_div).height();
    //    var z_layer_width = $(outer_div).width();
    //    $(outer_div).css('top',(doc_height-z_layer_height)/2);
    //    $(outer_div).css('left',(doc_width-z_layer_width)/2);
    //    $(outer_div).css('display','block');
    //    $('.mask').css('height',doc_height)
    //    $('.mask').css('display','');
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

