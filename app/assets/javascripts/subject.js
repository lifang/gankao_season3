// JavaScript Document

//控制做题页面主体高度
$(function(){
    // var doc_height = $(document).height();
    //var doc_width = $(document).width();
    var win_height = $(window).height();
    //var win_width = $(window).width();
    var head_height = $(".subject_head").height();
	
    var main_height = win_height-head_height;
    $(".subject_main").css('height',main_height-3);//3为subject_head的margin-bottom: 3px;
    $(".sub_side").css('height',main_height-3);
})

//选择题点击隐藏
$(function(){
    $(".question_title").bind("click",function(){
        var $q_div = $(this).siblings();
        if($q_div.is(":visible")){
            $q_div.hide();
            $(this).addClass("qt_height");
        }else{
            $q_div.show();
            $(this).removeClass("qt_height");
        }

    })
})


//提交错误弹出层

$(function(){
    //var doc_height = $(document).height();
    //var doc_width = $(document).width();
    var win_height = $(window).height();
    var win_width = $(window).width();
	
    var z_layer_height = $('.upErrorTo_tab').height();
    var z_layer_width = $('.upErrorTo_tab').width();
	
    //tab
    $('.upErrorTo_btn').bind('click',function(){
		
        $('.upErrorTo_tab').css('top',(win_height-z_layer_height)/2);
        $('.upErrorTo_tab').css('left',(win_width-z_layer_width)/2);
        $('.upErrorTo_tab').css('display','block');
        $('.mask').css('height',win_height);
        $('.mask').css('display','block');
    }
    )
    $('.x').click(function(){
        $('.upErrorTo_tab').css('display','none');
        $('.mask').css('display','none');
    })

})


function check_similar(category){
    $.ajax({
        async:true,
        type:'post',
        dataType:'json',
        url:"/learn/check_similar",
        data:{
            category:category
        },
        success :function (data){
            tishi_alert(data.message);
        }
    });
}


