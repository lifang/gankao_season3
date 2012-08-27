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

function show_tip(style){
    $(".tip_mask").show();
    $(style).show();
    generate_tip_div(style);
}

function close_pop(){
    $(".plan_tab").html("");
    $(".mask").hide();
    clearInterval(myTime.timeId);
}

