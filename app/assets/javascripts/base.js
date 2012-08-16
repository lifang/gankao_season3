$(document).ready(function(){
    $(".pl_img #unlock").click(function(){
        part_one_start();
    })
})


function part_one_start (){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/learn/task_dispatch?category=2",
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

