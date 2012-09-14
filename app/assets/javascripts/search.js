$(function(){
    $("#keywords").focus();
    $("#btnSearch").bind('click',function(){
        if($("#keywords").val()==""){
            tishi_alert('请输入关键字!');
        } else{
            window.location="/questions/show_result?keywords="+$("#keywords").val()+"&category="+category;
        }
    });

    $("#keywords").keydown(function(e){
        var keynumber; //键盘码
        if(window.event){
            //浏览器为IE
            keynumber = e.keyCode;
        }
        if(e.which){
            //浏览器为Firefox、Opera
            keynumber = e.which;
        }
        if(keynumber==13){
            $("#btnSearch").click();
        }
    });
});


$(function(){
    //问题页面提示时 title和description检验
    $("#askQuestion").click(function(){
        var description = $("#user_question_description").val();
        if($.trim(description).length == 0 || $.trim(description).length >250){
            tishi_alert("请填写补充的内容，不能为空，且不能超过250个字符。")
            return false;
        }
    });
});

//答疑
$(function(){
    $('.problem_box').click(
        function () {
            $(this).parent().parent().siblings().children('.load').slideUp("show");
            var current_id = $(this).attr("id").replace("problem_", "");
            var current_answer_div = $("#answer_" + current_id);
            if (current_answer_div.attr("class") == "load") {
                if (current_answer_div.css("display") == "block") {
                    current_answer_div.slideUp("slow");
                }else{
                    current_answer_div.slideDown("slow");
                }
            } else {
                var current_page = $("#current_page").val();
                $.ajax({
                    async:true,
                    dataType:'script',
                    url:"/questions/"+current_id+"/get_answers?current_page="+current_page,
                    complete: function(){
                        current_answer_div.slideDown("slow");
                    },
                    type:'post'
                });
                return false;
            }
        });
})

//答疑的我要回答检查
function check_answer(question_id) {
    if ($.trim($("#answer_text_" + question_id).val()).length == 0 ||
        $.trim($("#answer_text_" + question_id).val()).length > 200) {
        tishi_alert("请填写回答的内容，不能为空，且不能超过200个字符。")
        return false;
    }
    return true;
}

//检查发布的问题的字数
function check_question_content() {
    if ($.trim($("#askQuestion").val()).length == 0 ||
        $.trim($("#askQuestion").val()).length > 200) {
        tishi_alert("请填写回答的内容，不能为空，且不能超过200个字符。")
        return false;
    }
    return true;
}