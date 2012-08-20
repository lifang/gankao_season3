// JavaScript Document

//顶部人物信息弹出层 u_tab_div
function infoTab(i_tab,i_box,x){
    $(i_tab).click(function(e){
        $(i_box).css('display','block');
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

//答疑
$(function(){
    $('.problem_box').click(
        function () {
            var current_id = $(this).attr("id").replace("problem_", "");
            var current_answer_div = $("#answer_" + current_id);
            if (current_answer_div.attr("class") == "load") {               
                if (current_answer_div.css("display") == "block") {
                    current_answer_div.slideUp("slow");
                }else{
                    current_answer_div.slideDown("slow");
                }
            } else {
                $.ajax({
                    async:true,
                    dataType:'script',
                    url:"/questions/"+current_id+"/get_answers",
                    complete: function(){
                        current_answer_div.slideDown("slow");
                    },
                    type:'post'
                });
                return false;
            }
        }
        )
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
