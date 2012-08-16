//核对答案
function checkAnswer(){
    var result=$("#ls_answer").val();
    result=formatStr(result)
    if (result){
        //核对
        if(count==4){
            alert("没有回答的机会了");
            //显示正确答案
            $("div.trueFalse").parent().append("<span>"+"正确答案: "+listen_sentence+"</span>");
            $("#checkAnswer").hide();
        }else{
            //核对答案
            if(formatStr(listen_sentence)==result){
                answer_correct();
            }else{
                $("div.trueFalse").find("img").attr("src","/assets/false.png")
                count++;
            }
        }
        $("div.trueFalse").show();
    }else{
        alert("请输入答案");
    }
}
//去除标点符号并转为小写
function formatStr(str){
    str=str.replace(/([\(\)\[\]\{\}\^\$\+\-\*\?\,\.\"\'\|\/\\])/g,"").toLowerCase();
    return str;
}
//下一个问题
function nextQuestion(){
    $("div.middle").load("/learn/next_sentence?id="+id+"&type="+web_type+"&is_correct="+answer_mark)
}

function answer_correct(){
    answer_mark=true
    $("div.trueFalse").find("img").attr("src","/assets/true.png")
}
function answer_mistake(){
    
}

//播放音频
$(function(){
    $("#jquery_jplayer_1").jPlayer({
        ready: function (event) {
            $(this).jPlayer("setMedia",{
                mp3:url
            }
            );
        },
        swfPath: "../assets/flowplayer/flowplayer.swf",
        supplied: 'mp3',
        vmode:"window",
        solution:"flash, html",
        errorAlerts: false,
        warningAlerts: false
    });

    $("#playAudio").click(function(){
        $("#jquery_jplayer_1").jPlayer("play");
    });
});
$(function(){
    $("div.trueFalse").hide();
    
    $("#checkAnswer").bind("click",function(){
        checkAnswer();
    });
   
    $("#nextQuestion").bind("click",function(){
        nextQuestion();
    });
})