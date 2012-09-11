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
    window.clearInterval(local_timer);
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

function remember(current_step){
    $(".sign").attr('onclick', 'javascipt:void(0)');
    window.clearInterval(local_timer);
    $.ajax({
        async:true,
        dataType:'script',
        url:"/learn/i_have_remember",
        type:'post',
        data:{
            items : window.items,
            ids : window.ids,
            current_step : current_step
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
    //clearInterval(myTime.timeId);
    window.clearInterval(local_timer);
}

$.fn.reorder = function() {
    //random array sort from
    //http://javascript.about.com/library/blsort2.htm
    function randOrd() {
        return(Math.round(Math.random())-0.5);
    }
    return($(this).each(function() {
        var $this = $(this);
        var $children = $this.children();
        var childCount = $children.length;

        if (childCount > 1) {
            $children.remove();

            var indices = new Array();
            for (i=0;i<childCount;i++) {
                indices[indices.length] = i;
            }
            indices = indices.sort(randOrd);
            $.each(indices,function(j,k) {
                $this.append($children.eq(k));
            });
        }
    }));
}


