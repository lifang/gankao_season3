//复习计划上一页
function pre_page(plan_id, chapter_num) {
    $(".m_content .pn_btn button").show();
    var package_len = $(".mc_box > div").length;
    var l_show_index = $(".mc_box > div").index($(".plan_list:visible:last")) + 1;
    var current_page = (l_show_index%10 > 0) ? (parseInt(l_show_index/10) + 1) : parseInt(l_show_index/10);
    if (current_page == 1) {
        if (chapter_num != 1) {
            show_chapter(plan_id, chapter_num, "pre");
        } else {
            $(".m_content .pn_btn button:first").hide();
        }
    } else {
        var la_f_index = (current_page - 2) * 10;
        $(".mc_box > div").hide();
        for (var i=la_f_index; i<la_f_index+10 && i<package_len; i++) {
            if ($(".mc_box > div")[i] != null && $(".mc_box > div")[i] != undefined) {
                $(".mc_box > div")[i].style.display = "block";
            }
        }
        if (chapter_num == 1 && current_page - 1 == 1) {
            $(".m_content .pn_btn button:first").hide();
        }
    }
}

//复习计划下一页
function next_page(plan_id, chapter_num) {
    $(".m_content .pn_btn button").show();
    var package_len = $(".mc_box > div").length;
    var total_page = (package_len%10 > 0) ? (parseInt(package_len/10) + 1) : parseInt(package_len/10);
    var l_show_index = $(".mc_box > div").index($(".plan_list:visible:last")) + 1;
    var current_page = (l_show_index%10 > 0) ? (parseInt(l_show_index/10) + 1) : parseInt(l_show_index/10);
    if (current_page == total_page) {
        if (chapter_num != 3) {
            show_chapter(plan_id, chapter_num, "next");
        } else {
            $(".m_content .pn_btn button:last").hide();
        }        
    } else {
        var next_f_index = current_page * 10;
        $(".mc_box > div").hide();
        for (var i=next_f_index; i<next_f_index+10 && i<package_len; i++) {
            if ($(".mc_box > div")[i] != null && $(".mc_box > div")[i] != undefined) {
                $(".mc_box > div")[i].style.display = "block";
            }
        }
        if (chapter_num == 3 && current_page + 1 == total_page) {
            $(".m_content .pn_btn button:last").hide();
        }
    }
}

function show_chapter(plan_id, chapter_num, direction) {
    $.ajax({
        async:true,
        dataType:'script',
        url:"/plans/show_chapter",
        data:{
            plan_id : plan_id,
            chapter_num : chapter_num,
            direction : direction
        },
        type:'post'
    });
    return false;
}

//弹出开始练习框
function start_practice(category_id) {
    setCookie("first_study", "1", 86400000, '/');
    dispatch(category_id);
}

