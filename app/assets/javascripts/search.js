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


