$(document).ready(function(){
    $(".pl_img #unlock").click(function(){
        part_one_start();
    })
})


function part_one_start (){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/learn/task_dispatch",
        type:'get'
    })
}
function send_message (url){
    $.ajax({
        async:true,
        dataType:'script',
        url:url,
        type:'get'
    })
}
function hedui(){
    if($("#SID").attr("value").toLowerCase() == $(".answer_input").attr("value").trim().toLowerCase()){
        $(".trueFalse").html("<img src='assets/true.png' />");
    }else{
        $(".trueFalse").html("<img src='assets/false.png' />");
    }
}
