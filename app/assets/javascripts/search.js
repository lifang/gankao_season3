$(function(){
    $("#keywords").focus();
    $("#btnSearch").bind('click',function(){
        if($("#keywords").val()==""){
            alert('请输入关键字!');
        }
        else{
            window.location="search?keywords="+$("#keywords").val();
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
    //点击li获取a的值转向
    $("ul.subnav li").click(function(){
        var href=$(this).children("a").attr("href");
        if(href){
            window.location=href;
        }
    });
});
$(function(){
   //问题页面提示时 title和description检验
   $("#askQuestion").click(function(){
      var title=$("#user_question_title").val();
      var description=$("#user_question_description").val();

      if(!title){
          alert("请输入问题!");
          return false;
      }
      if(!description){
          alert("请输入补充的内容!");
          return false;
      }
   });
});


