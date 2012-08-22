//$(document).ready(function(){
//    $(".pl_img #unlock").click(function(){
//        part_one_start();
//    })
//})
//
//function part_one_start (){
//    $.ajax({
//        async:true,
//        dataType:'script',
//        url:"/learn/task_dispatch?category=2",
//        type:'get'
//    })
//}

window.items;
window.ids;

function send_message (url){
    $.ajax({
        async:true,
        dataType:'script',
        url:url,
        type:'get'
    })
}

function dispatch(category){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/learn/task_dispatch",
        type:'post',
        data:{
            items : window.items,
            ids : window.ids,
            category : category
        }
    })
}
function jude(url, flag, redirct){
    $.ajax({
        async:true,
        dataType:'script',
        url:url,
        type:'post',
        data:{
            items : window.items,
            ids : window.ids,
            flag : flag,
            redirct : redirct
        }
    })
}

function remember(){
    $.ajax({
        async:true,
        dataType:'script',
        url:"/learn/i_have_remember",
        type:'post',
        data:{
            items : window.items,
            ids : window.ids
        }
    })
}

function close_pop(){
    $(".plan_tab").html("");
}

