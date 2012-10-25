
//核对答案
function checkAnswer(){
    var result=$("#ls_answer").val();
    if (result){
        is_answer=true;
        //核对
        if(count==4){
            alert("没有回答的机会了");
            //显示正确答案
            $("div.trueFalse").parent().append("<span>"+"正确答案: "+listen_sentence+"</span>");
            $("#checkAnswer").hide();
        }else{
            //核对答案
            if(formatStr(listen_sentence)==formatStr(result)){
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
    $("div.middle").load("/learn/next_sentence?id="+id+"&type="+web_type+"&is_correct="+answer_mark+"&is_answer="+is_answer+"&index="+index+"&ids="+listen_ids)
}

function answer_correct(){
    answer_mark=true;
    is_answer=true;
    $("div.trueFalse").find("img").attr("src","/assets/true.png");
}
//播放音频
$(function(){
    flowplayer("player", "/assets/flowplayer/flowplayer-3.2.7.swf", {
        clip: {
            url: '/music.mp3'
        }
    });

    $("#playAudio").click(function(){
        flowplayer('player').play();
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
});