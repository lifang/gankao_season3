// JavaScript Document
//jQuery(window).height()代表了当前可见区域的大小，而jQuery(document).height()则代表了整个文档的高度，可视具体情况使用注意当浏览器窗口大小

//控制做题页面主体高度
$(function(){
    // var doc_height = $(document).height();
    //var doc_width = $(document).width();
    var win_height = $(window).height();
    //var win_width = $(window).width();
    var head_height = $(".head").height();
    var mainTop_height = $(".m_top").height();
    var foot_height = $(".foot").height();

    var main_height = win_height-(head_height+mainTop_height+foot_height);
    $(".m_side").css('height',main_height-12);//12为head的padding的12px
    $(".main").css('height',main_height-12+34);//34是m_top的高度，
})

//控制其他页面主体高度
$(function(){
    // var doc_height = $(document).height();
    //var doc_width = $(document).width();
    var win_height = $(window).height();
    //var win_width = $(window).width();
    var head_height = $(".head").height();
    var foot_height = $(".foot").height();

    var main_height = win_height-(head_height+foot_height);
    $(".main_Div").css('height',main_height-12);
})


//tooltip提示
$(function(){
    var x = -20;
    var y = 15;
    $(".tooltip").mouseover(function(e){
        var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.name+"</div></div>";
        $("body").append(tooltip);
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        }).show("fast");
    }).mouseout(function(){
        $(".tooltip_box").remove();
    }).mousemove(function(e){
        $(".tooltip_box").css({
            "top":(e.pageY+y)+"px",
            "left":(e.pageX+x)+"px"
        })
    });
})



//填空拖拽-------
$(function(){
    var drag_tk_height = $(".drag_tk").height();
    $(".drag_tk_box").css("height",drag_tk_height);
})




//提示框样式设定
function generate_flash_div(style) {
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = jQuery(window).width();
    var z_layer_height = jQuery(style).height();
    var z_layer_width = jQuery(style).width();
    jQuery(style).css('top',(win_height-z_layer_height)/2 + scolltop);
    jQuery(style).css('left',(win_width-z_layer_width)/2);
    jQuery(style).css('display','block');
}

//提示框弹出层
function show_flash_div() {
    $('.tishi_tab').stop();
    generate_flash_div(".tishi_tab");
    $('.tishi_tab').delay(2500).fadeTo("slow",0,function(){
        $(this).remove();
    });
}

//创建元素
function create_element(element, name, id, class_name, type, ele_flag) {
    var ele = document.createElement("" + element);
    if (name != null)
        ele.name = name;
    if (id != null)
        ele.id = id;
    if (class_name != null)
        ele.className = class_name;
    if (type != null)
        ele.type = type;
    if (ele_flag == "innerHTML") {
        ele.innerHTML = "";
    }
    else {
        ele.value = ele_flag;
    }
    return ele;
}

//弹出错误提示框
function tishi_alert(str){
    var div = create_element("div",null,"flash_notice","tishi_tab",null,null);
    var p = create_element("p","","","","innerHTML");
    p.innerHTML = str;
    div.appendChild(p);
    var body = jQuery("body");
    body.append(div);
    show_flash_div();
}

function check_compelte(){
    var questions=$("#questions").val().split(";");
    for(var i=0;i<=questions.length-1;i++){
        var put_score=$("#score_"+questions[i]).val();
        var score=$("#fact_score_"+questions[i]).html();
        if(put_score==null||put_score==""||isNaN(parseInt(put_score))||parseInt(put_score)<0||parseInt(put_score)>parseInt(score)){
            var problem=questions[i].split("_");
            tishi_alert("请检查第"+(parseInt(problem[0])+1) +"大题批阅分数");
            setCookie("show_problem",parseInt(problem[0]));
            $("div[id*='single_problem_']").css("display","none");
            $("#single_problem_"+getCookie("show_problem")).css("display","");
            $('.pro_question_list').addClass('p_q_line');
            $("#"+questions[i]).removeClass("p_q_line");
            return false;
        }
    }
    tishi_alert("所有试题阅卷完毕，等待提交！");
    var score_reason={};
    for(var k=0;k<=questions.length-1;k++){
        var input_score=$("#score_"+questions[k]).val();
        var input_reason=$("#reason_"+questions[k]).val();
        var question_id=questions[k].split("_")[1];
        score_reason[question_id]=[parseInt(input_score),input_reason];
    }
    $.ajax({
        async:true,
        type: "POST",
        url: "/exam_raters/over_answer.json",
        dataType: "json",
        data : {
            score_reason :score_reason,
            id :$("#rater_id").val()
        },
        success : function(data) {
            var examination=data.examination_id;
            var  rater=data.rater_id;
            tishi_alert(data.notice);
            window.location.href="/exam_raters/"+examination +"/reader_papers?rater_id="+rater;
        }
    });
}

function prev_problem(){
    if(parseInt(getCookie("show_problem"))==0){
        tishi_alert("当前已是第一题");
        return false;
    }
    $('.pro_question_list').addClass('p_q_line');
    setCookie("show_problem",parseInt(getCookie("show_problem"))-1);
    $("#global_problem_index").html(parseInt(getCookie("show_problem"))+1);
    $("div[id*='single_problem_']").css("display","none");
    $("#single_problem_"+getCookie("show_problem")).css("display","");
    $("#single_problem_"+getCookie("show_problem")+" .pro_qu_t" ).first().trigger("onclick");
    $("#jplayer_button_"+getCookie("show_problem")).trigger("onclick");
}

function next_problem(){
    if(parseInt(getCookie("show_problem"))==total_problem-1){
        tishi_alert("当前已是最后一题");
        return false;
    }
    $('.pro_question_list').addClass('p_q_line');
    setCookie("show_problem",parseInt(getCookie("show_problem"))+1);
    $("#global_problem_index").html(parseInt(getCookie("show_problem"))+1);
    $("div[id*='single_problem_']").css("display","none");
    $("#single_problem_"+getCookie("show_problem")).css("display","");
    $("#single_problem_"+getCookie("show_problem")+" .pro_qu_t" ).first().trigger("onclick");
    $("#jplayer_button_"+getCookie("show_problem")).trigger("onclick");
}

function save_score(p_q_id,score){
    var put_score=$("#score_"+p_q_id).val();
    if(put_score==""||isNaN(parseInt(put_score))||parseInt(put_score)<0||parseInt(put_score)>parseInt(score)){
        tishi_alert("此小题批阅分数有误");
        return false;
    }
    var questions=$("#questions").val().split(";");
    if(questions.indexOf(p_q_id)>=0&&questions.indexOf(p_q_id)<questions.length-1){
        var problem=questions[questions.indexOf(p_q_id)+1].split("_");
        setCookie("show_problem",problem);
        $("div[id*='single_problem_']").css("display","none");
        $("#single_problem_"+getCookie("show_problem")).css("display","");
        $('.pro_question_list').addClass('p_q_line');
        $("#"+questions[questions.indexOf(p_q_id)+1]).removeClass("p_q_line");
    }
    if(questions.indexOf(p_q_id)==questions.length-1){
        if(confirm("是否完成批改")){
            $($(".green")[0]).trigger("onclick");
        }
    }
}


function get_flowplayer(selector,audio_src){
    $("#jplayer_location_"+selector).append($("#flowplayer_loader"));
    $f("flowplayer", "/assets/flowplayer/flowplayer-3.2.7.swf", {
        plugins: {
            controls: {
                fullscreen: false,
                height: 30,
                autoHide: false
            }
        },
        clip: {
            autoPlay: false,
            onBeforeBegin: function() {
                this.close();
            }
        },
        onLoad: function() {
            this.setVolume(90);
            this.setClip(audio_src);
        }
    });
}

