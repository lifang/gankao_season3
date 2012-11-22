//加载试卷
function load_paper() {
    //load已有的答案
    var paper_id = $("#paper_id").val();
    var examination_id = $("#examination_id").val();
    load_answer(paper_id, examination_id);
    setTimeout(function(){
        get_exam_time(examination_id);
    }, 100);
}
if (window.onbeforeunload == undefined || window.onbeforeunload == null) {
    window.onbeforeunload = function() {
        return "您的试卷尚未提交，确定要离开么?";
    }
}

//获取考试的时间
function get_exam_time(examination_id){
    var user_id = $("#user_id").val();
    $.ajax({
        async:true,
        complete:function(request){
            $("#true_exam_time").html(request.responseText);
            load_exam_tiem(request.responseText);
        },
        data:{
            user_id :user_id
        },
        dataType:'script',
        url:"/simulations/"+ examination_id +"/get_exam_time",
        type:'post'
    });
    return false;
}

//加载是否是定时考试
function load_exam_tiem(time) {
    if (time == "不限时") {
        start = 0;
        $("#exam_time").html("不限时");
    } else {
        time = Math.round(time*10)/10;
        var h = Math.floor(time/3600) < 10 ? ("0" + Math.floor(time/3600)) : Math.floor(time/3600);
        var m = Math.floor((time%3600)/60) < 10 ? ("0" + Math.floor((time%3600)/60)) : Math.floor((time%3600)/60);
        $("#exam_time").html("剩余时间  " + h + ":" + m);
        start = time;
        is_fix_time = true;
        //此处定义hash的方法要改
        block_start_hash = new Hashtable();
        block_end_hash = new Hashtable();
    }
    setTimeout(function(){
        create_paper();
    }, 500);
}

//创建试卷
function create_paper() {
    //显示基本信息部分
    $("#problem_ids").attr("value", "");
    $("#paper_title").html(papers.paper.base_info.title);
    $("#leaving_num").html(papers.paper.total_num);
    if (papers.paper.blocks != undefined && papers.paper.blocks.block != undefined) {
        var blocks = papers.paper.blocks.block;
        get_block_id(blocks);
        var bocks_div = $("#blocks");
        if (tof(blocks) == "array") {
            for (var i=0; i<blocks.length;i++) {
                create_block(bocks_div, blocks[i]);
            }
        } else {
            create_block(bocks_div, blocks);
        }
        next_last_index();
    }
    //生成拖动框
    if ($(".dragDrop_box").length > 0) {
        $(".dragDrop_box").droppable({
            drop: function( event, ui ) {
                $(this).html(ui.draggable.html());
                //                ui.draggable.addClass("dropOver");
                already_drag_li();
                show_que_save_button($(this).attr("id").split("question_answer_")[1]);
            }
        });
        already_drag_li();
    }    
    setTimeout(function(){
        show_exam_time();
    }, 500);
    local_save_start();
//load_scroll();
}

//显示已被拖选过的框的颜色
function already_drag_li() {
    var all_drag = $(".dragDrop_box");    
    var drag_lis = new Array();
    var all_lis = $(".drag_tk_box div ul li");
    for (var j=0; j<all_lis.length; j++) {
        drag_lis.push(all_lis[j].innerHTML);
        all_lis[j].className = "";
        
    }
    for (var i=0; i<all_drag.length; i++) {
        var index = $.inArray(all_drag[i].innerHTML,drag_lis);
        if (index > -1) {
            all_lis[index].className = "dropOver";
        }
    }
}

function get_block_id(blocks) {
    if (tof(blocks) == "array") {
        for (var i=0; i<blocks.length;i++) {
            if ($("#block_ids").val() != "") {
                $("#block_ids").attr("value", ($("#block_ids").val() + "," + blocks[i].id));
            }else {
                $("#block_ids").attr("value", blocks[i].id);
            }
        }
    } else {
        $("#block_ids").attr("value", blocks.id);
    }
}

//添加试卷块
var question_num = 1;   //根据提点显示导航
var block_block_flag = 0;   //记录打开的模块
var mp3_url = [];
function create_block(bocks_div, block) {
    if (is_fix_time) {
        return_block_exam_time(block.id, block.start_time, block.time);
    }
    var block_title = block.base_info.title;
    var block_div = create_element("div", null, "block_" + block.id, "tp_left", null, "innerHTML");
    block_div.style.display = "none";
    bocks_div.append(block_div);
    var part_message = create_element("div", null, "block_show", "part_head border_radius", null, "innerHTML");
    var block_str = block_title;
    if (block.time != null && block.time != "" && block.time != "0") {
        block_str += " (<span id='b_timer_"+ block.id +"'>"+ block.time +"</span> minutes)";
    }
    part_message.innerHTML = "<h1 id='b_title_"+ block.id +"'>" + block_str + "</h1>";
    //此处的增加和注释掉是为了真题的模考模式解决音频听力问题
    if (block_str.match("Listening") != null)  {
        part_message.innerHTML += "<p>"+ generate_jplayer_div(block.id)+"</p>";
    }
    block_div.appendChild(part_message);
    //试卷导航展开部分
    var navigation_div = $("#paper_navigation");
    var block_nav_div = create_element("div", null, "block_nav_"+block.id, "first_title", null, "innerHTML");
    if (is_fix_time && block_start_hash.get(block.id) != null && block_start_hash.get(block.id) != "") {
        block_nav_div.innerHTML = "<p onclick='javascript:hand_open_nav(\""+block.id+"\");'>"+ block_title + "</p>";
    } else {
        block_nav_div.innerHTML = "<p onclick='javascript:open_nav(\""+block.id+"\");'>"+ block_title + "</p>";
    }
    navigation_div.append(block_nav_div);
    var ul = create_element("ul", null, "nav_block_" + block.id, "second_menu", null, "innerHTML");
    ul.style.display = "none";
    block_nav_div.appendChild(ul);
    //判断problem的存在
    if (block.problems != undefined && block.problems.problem != undefined) {
        var problems = block.problems.problem;
        if (tof(problems) == "array") {
            for (var j=0; j<problems.length; j++) {
                create_problem(part_message, block.id, block_div, problems[j], ul);
            }
        } else {
            create_problem(part_message, block.id, block_div, problems, ul);
        }
    }
    //显示听力
    if ($("#jquery_jplayer_" + block.id).attr("id") != undefined) {
        generate_jplayer(mp3_url, block.id);
    }
    if (block_block_flag == 0 && (is_fix_time == false || (is_fix_time && (block_start_hash.get(block.id) == ""
        || (return_giving_time(block_start_hash.get(block.id)) >= start &&
            (block_end_hash.get(block.id) == "" ||
                return_giving_time(block_end_hash.get(block.id)) < start)))))) {
        open_block_nav(block.id);
        block_block_flag = 1;
    }
    
}

//上一部分、下一部分
function next_last_index() {
    if ($("#block_ids").val() != "") {
        var block_ids = $("#block_ids").val().split(",");
        if (block_ids != null) {
            if (block_ids.length > 1) {
                for (var i=0; i<block_ids.length; i++) {
                    var next_div = null;
                    if ($("#page_btn_" + block_ids[i]).attr("id") == null || $("#page_btn_" + block_ids[i]).attr("id") == undefined) {
                        next_div = create_element("div", null, "page_btn_" + block_ids[i], "page_btn", null, "innerHTML");
                    } else {
                        next_div = document.getElementById("page_btn_" + block_ids[i]);
                    }
                    var method_str = "";
                    var next_method = "";
                    var next_block_id = "";
                    var last_block_id = "";
                    if (block_ids.indexOf(block_ids[i]) == 0) {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        method_str = (is_fix_time && block_start_hash.get(next_block_id) != null && block_start_hash.get(next_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:" + method_str
                        + "(\""+ next_block_id +"\");'>下一部分</a>";
                    } else if (block_ids.indexOf(block_ids[i]) == block_ids.length - 1) {
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        method_str = (is_fix_time && block_start_hash.get(last_block_id) != null && block_start_hash.get(last_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:" + method_str
                        + "(\""+ last_block_id +"\");'>上一部分</a>";
                    } else {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        method_str = (is_fix_time && block_start_hash.get(next_block_id) != null && block_start_hash.get(next_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        next_method = (is_fix_time && block_start_hash.get(last_block_id) != null && block_start_hash.get(last_block_id) != "")
                        ? "hand_open_nav" : "open_nav";
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:"
                        + method_str + "(\""+ next_block_id +"\");'>下一部分</a><a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:" + next_method
                        + "(\""+ last_block_id +"\");'>上一部分</a>";
                    }
                    $("#block_" + block_ids[i]).append(next_div);
                }
            }
        }
    }
}

//返回模块的考试结束时间
function return_block_exam_time(block_id, start_time, time) {
    var end_time = "";
    var b_start_time = "";
    if (start_time != null && start_time != "") {
        var t = start_time.split(":");
        var h = new Number(t[0]);
        var m = new Number(t[1]);
        var sh = h < 10 ? ("0" + h) : h;
        var sm = m < 10 ? ("0" + m) : m;
        b_start_time = sh + ":" + sm + ":00";
        if (time != "" && time != "0") {
            var total_m = h * 60 + m - new Number(time);
            h = (total_m >= 60) ? Math.floor(total_m/60) : 0;
            m = (total_m >= 60) ? new Number(total_m%60) : total_m;
            var eh = h < 10 ? ("0" + h) : h;
            var em = m < 10 ? ("0" + m) : m;
            end_time = eh + ":" + em + ":00";
        }
    }
    block_start_hash.put(block_id, b_start_time);
    block_end_hash.put(block_id, end_time);
}

//打开模块
function open_nav(block_id) {
    var block_ids = $("#block_ids");
    if (block_ids.val() != undefined && block_ids.val() != "") {
        var b_ids = block_ids.val().split(",");
        if (b_ids != null) {
            for (var i=0; i<b_ids.length; i++) {
                close_block_nav(b_ids[i]);
            }
        }
    }
    open_block_nav(block_id);
}

//打开模块
function open_block_nav(block_id) {
    $("#block_nav_" + block_id).addClass("highLight");
    $("#nav_block_" + block_id).css("display", "block");
    $("#block_" + block_id).css("display", "block");
    window.scrollTo(0, 0);
    if (is_fix_time) {
        start_block_audio(block_id);
    }
    //给移动拖动框加事件
    if ($("#block_" + block_id + " .drag_tk_box").length > 0) {
        for (var m=0; m<$("#block_" + block_id + " .drag_tk_box").length; m++) {
            fix_div_top.put($("#block_" + block_id + " .drag_tk_box")[m].id, $("#block_" + block_id + " .drag_tk_box")[m].offsetTop);
            var problem_id = $("#block_" + block_id + " .drag_tk_box")[m].id.split("problem_drag_");
            var last_top = $("#problem_"+problem_id[1]).get(0).offsetTop
            + parseInt($("#problem_"+problem_id[1]).css("height").split("px")[0]);
            self.setInterval("fix_top("+last_top+", '"+$("#block_" + block_id + " .drag_tk_box")[m].id+"');",100);
        }
    }
}

//关闭模块
function close_block_nav(block_id) {
    $("#block_nav_" + block_id).removeClass("highLight");
    $("#nav_block_" + block_id).css("display", "none");
    $("#block_" + block_id).css("display", "none");
}

//根据定时返回时间
function return_giving_time(time) {
    var times =  time.split(":");
    var ss = new Number(times[2]) + (new Number(times[1])) * 60 + (new Number(times[0])) * 3600;
    return ss;
}

//手动打开模块
function hand_open_nav(block_id) {
    if (is_fix_time) {
        var fs = start;
        var flash_div = null;
        var bs = null;
        var end_time_flag = false;
        if (block_end_hash.get(block_id) != null && block_end_hash.get(block_id) != "") {
            bs = return_giving_time(block_end_hash.get(block_id));
        }
        if (block_start_hash.get(block_id) != null && block_start_hash.get(block_id) != "") {
            var ss = return_giving_time(block_start_hash.get(block_id));
            if (ss < fs) {
                var total_m = fs -  ss;
                var s = Math.floor((total_m%3600)%60);
                var m = Math.floor((total_m%3600)/60);
                var h = Math.floor(total_m/3600);
                var ms = s < 10 ? ("0" + s) : s;
                var sm = m < 10 ? ("0" + m) : m;
                var sh = h < 10 ? ("0" + h) : h;
                tishi_alert("当前部分的开始答题时间为"+block_start_hash.get(block_id)+"，还有"
                    +sh+"时"+sm+"分"+ms+"秒才能进入该部分进行答题。");
            }
            else {
                end_time_flag = true;
            }
        } else {
            end_time_flag = true;
        }
        if (end_time_flag == true) {
            if (bs == null || bs < fs) {
                open_nav(block_id);
            } else {
                tishi_alert("当前部分答题时间固定，答题时间已过。")
            }
        }
    } else {
        open_nav(block_id);
    }
}

//生成试卷提点导航
function create_question_navigation(block_nav_div, question, problem_id, question_num) {
    var question_nav_li = create_element("li", null, "question_nav_"+question.id, null, null, "innerHTML");
    question_nav_li.innerHTML = "<a href='javascript:void(0);' id='a_que_nav_"+ question.id
    +"' onclick='javascript:get_question_height(\""+question.id+"\", \""+problem_id+"\");'>"+ question_num +"</a>";
    block_nav_div.appendChild(question_nav_li);
}

//取得点击的题点的高度
function get_question_height(question_id, problem_id) {
    window.onbeforeunload = null;
    var p_height = 0;
    var block_div = document.getElementById("problem_" + problem_id).parentNode;
    var all_divs = block_div.getElementsByTagName("div");
    if (all_divs != null) {
        for (var i=0; i<all_divs.length; i++) {
            if (all_divs[i].className == "part_box" || all_divs[i].className == "part_head border_radius") {
                if (all_divs[i].id == "problem_"+problem_id) {
                    break;
                } else {
                    p_height += all_divs[i].offsetHeight;
                }
            }
        }
    }
    var question_ids = $("#question_ids_" + problem_id).val();
    if ($("#problem_title_" + problem_id).attr("id") != undefined) {
        p_height += $("#problem_title_" + problem_id).get(0).offsetHeight;
    }
    if (question_ids != null) {
        var q_ids = question_ids.split(",");
        if (q_ids != null) {
            for (var j=0; j<q_ids.length; j++) {
                if (q_ids[j] == question_id) {
                    break;
                }
                else {
                    if ($("#que_out_" + q_ids[j]).attr("id") != undefined) {
                        p_height += $("#que_out_" + q_ids[j]).get(0).offsetHeight;
                    }
                }
            }
        }
    }
    window.scrollTo(100, p_height);
}

//添加problem
var fix_div_top = new Hashtable();
function create_problem(part_message, block_id, block_div, problem, block_nav_div) {
    var problem_div = create_element("div", null, null, "part_box", null, "innerHTML");
    block_div.appendChild(problem_div);
    if (problem.id == null || problem.id == undefined) {
        var question_text_explain = create_element("div", null, null, "question_explain", null, "innerHTML");
        question_text_explain.innerHTML = "<p><em>" + problem.part_description + "</em></p>";
        problem_div.appendChild(question_text_explain);
    }
    else {
        problem_div.id = "problem_" + problem.id;
        if (problem.description != null && problem.description != undefined && problem.description != "") {
            var q_t_e = create_element("div", null, null, "question_explain", null, "innerHTML");
            q_t_e.innerHTML = "<p><em>" + problem.description + "</em></p>";
            problem_div.appendChild(q_t_e);
        }
        if (problem.question_type == "1") {
            var drop_div = create_element("div", null, null, "question_text", null, "innerHTML");
            problem_div.appendChild(drop_div);
        }

        if (problem.title != null && problem.title != "") {
            var titles = problem.title.split("<time>");
            var complete_title = "";
            var back_server_path = $("#back_server_url").val();
            if (titles[0] != "" || titles[2] != "") {
                if (titles[0] != null && titles[0] != "") {
                    complete_title += replace_title_span(titles[0], problem.id);
                }
                if (titles[2] != null && titles[2] != "") {
                    complete_title += replace_title_span(titles[2], problem.id);
                }
            }
            if (complete_title.split("((mp3))").length > 1) {
                //为了解决真题的模考模式每道听力都有音频的
                mp3_url.push({
                    mp3 : ""+back_server_path+complete_title.split("((mp3))")[1]
                });
                //part_message.innerHTML += is_has_audio(block_id, "((mp3))"+complete_title.split("((mp3))")[1]+"((mp3))");
                complete_title = complete_title.split("((mp3))")[2];
            }
            if (complete_title != "") {
                var out_que_div = create_element("div", null, "problem_title_" + problem.id, "question_text", null, "innerHTML");
                out_que_div.innerHTML = "<p>" + complete_title + "</p>";
                problem_div.appendChild(out_que_div);
            }
        }
        var question_id_input = create_element("input", "question_ids", "question_ids_" + problem.id, null, "hidden", "value");
        var drag_li_arr = [];  //拖动框的div        
        var is_nomal = 0; //用来记录是题目中的小题标记
        if (problem.question_type == "0" || problem.question_type == null || problem.question_type == undefined) {
            if (problem.questions != undefined && problem.questions.question != undefined) {
                var questions = problem.questions.question;
                if (tof(questions) == "array") {
                    for (var j=0; j<questions.length; j++) {
                        create_question_navigation(block_nav_div, questions[j], problem.id, question_num);
                        create_question(problem.id, question_id_input, problem_div, questions[j], question_num, drag_li_arr);
                        question_num ++ ;
                    }
                } else {
                    create_question_navigation(block_nav_div, questions, problem.id, question_num);
                    create_question(problem.id, question_id_input, problem_div, questions, question_num, drag_li_arr);
                    question_num ++ ;
                }
            }
        }
        else {
            is_nomal = 1;
            drag_problem(out_que_div, problem, block_nav_div, drag_li_arr, question_id_input);
        }
        if (drag_li_arr.length > 0) {
            if (drop_div != null) {                
                create_words_div(drop_div, problem.id, drag_li_arr);
            }
        } else {
            $(drop_div).remove();
        }
        //添加question所需div
        problem_div.appendChild(question_id_input);
        var is_answer_input = create_element("input", "is_answer", "is_answer_" + problem.id, null, "hidden", "value");
        problem_div.appendChild(is_answer_input);
        var is_sure_input = create_element("input", "is_sure", "is_sure_" + problem.id, null, "hidden", "value");
        problem_div.appendChild(is_sure_input);

        $("#problem_ids").attr("value",  $("#problem_ids").val() + "" + problem.id + ",");
        if (answer_hash != null) {
            load_un_sure_question(problem.id, is_nomal);
            is_problem_answer(problem.id, is_nomal);
            alreay_answer_que_num();
        }
        
    }
}

function drag_problem(title_div, problem, block_nav_div, drag_li_arr, question_id_input) {
    var new_title = title_div.innerHTML;
    if (problem.questions != undefined && problem.questions.question != undefined) {
        var questions = problem.questions.question;
        var rep_str = "";
        if (tof(questions) == "array") {
            for (var j=0; j<questions.length; j++) {
                rep_str = "<span class='span_tk' id='que_out_"+ questions[j].id +"'></span>";
                if (new_title.indexOf("((sign))") > -1) {
                    new_title = new_title.replace(/\(\(sign\)\)/, rep_str);
                    title_div.innerHTML = new_title;
                    create_question_navigation(block_nav_div, questions[j], problem.id, question_num);
                    create_drag_question(problem.id, question_id_input, questions[j], drag_li_arr);
                    question_num ++ ;
                    new_title = title_div.innerHTML;
                }
            }
        } else {
            if (new_title.indexOf("((sign))") > -1) {
                rep_str = "<span class='span_tk' id='que_out_"+ questions.id +"'></span>";
                new_title = new_title.replace(/\(\(sign\)\)/, rep_str);
                title_div.innerHTML = new_title;
                create_question_navigation(block_nav_div, questions, problem.id, question_num);
                create_drag_question(problem.id, question_id_input, questions, drag_li_arr);
                question_num ++ ;
                new_title = title_div.innerHTML;
            }
        }
    }
    
    
}

//增加提点保存和不确定按钮
function add_que_save_button(parent_div, question_id, problem_id) {
    var buttons_div = create_element("div", null, "save_button_" + question_id, "p_question_btn", null, "innerHTML");
    buttons_div.innerHTML = "<input type='button' name='question_submit' class='save' onclick='javascript:generate_question_answer(\""
    + question_id +"\", \""+problem_id+"\", \"1\", 0);' value=''/>";
    buttons_div.innerHTML += "<input type='button' name='question_button' class='Uncertain' onclick='javascript:generate_que_unsure_answer(\""
    + question_id +"\", \""+problem_id+"\", \"0\", 0);' value=''/>";
    buttons_div.style.display = "none";
    parent_div.appendChild(buttons_div);
}

//显示提点按钮
function show_que_save_button(question_id) {
    var save_button = $("#save_button_" + question_id);
    if (save_button.css("display") == "none") {
        save_button.css("display", "block");
    }
}

//创建可拖动的div
function create_drag_question(problem_id, question_id_input, question, drag_li_arr) {
    $("#all_question_ids").attr("value", $("#all_question_ids").val() + question.id + ",");
    question_id_input.value += "" + question.id + ",";
    var question_str = "<input type='hidden' name='question_type' id='question_type_"+ question.id
    +"' value='"+ question.correct_type +"'/>"
    + "<input type='hidden' name='question_sure' id='question_sure_"+ question.id + "' value='' />";
    if ((parseFloat(question.correct_type) == 0) || (parseFloat(question.correct_type) == 2)) {
        if (question.questionattrs != undefined && question.questionattrs != null) {
            var user_answer = (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "")
            ? answer_hash.get(question.id)[0] : "";
            question_str += "<span onmouseout=\"javascript:close_select_ul(event, this, '"+ question.id
            +"');\"><span class='select_span' name='question_attr_"+ question.id +"' id='question_attr_"
            + question.id +"' onclick='javascript:select_ul(\""+question.id+"\")'>"+ user_answer +"</span>";
            var que_attrs = question.questionattrs.split(";-;");
            question_str += "<span class='select_ul' id='select_ul_"+ question.id +"' style='display:none;'>";
            for (var i=0; i<que_attrs.length; i++) {
                question_str += "<span class='select_li' onclick='javascript:select_li(this, \""+question.id+"\");'>"
                + que_attrs[i] +"</span>";
            }
            question_str += "</span></span>";
            $("#que_out_" + question.id).html(question_str);
        } 
    } else if ((parseFloat(question.correct_type) == 3) || (parseFloat(question.correct_type) == 5)) {
        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
            question_str += "<input class='input_tk'"
            + " id='question_answer_"+ question.id +"' name='question_answer_"
            + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
            +"\", 0)' onblur='javascript:window.clearInterval(change_length);' style='width:"
            + erea_with(answer_hash.get(question.id)[0]) +";height:20px;' value='" + answer_hash.get(question.id)[0] +"' />";
        } else {
            question_str += "<input class='input_tk' id='question_answer_"+ question.id
            +"' name='question_answer_" + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
            +"\", 0)' onblur='javascript:window.clearInterval(change_length);' value=''/>";
        }
        $("#que_out_" + question.id).html(question_str);
    } else if (parseFloat(question.correct_type) == 1) {
        $("#que_out_" + question.id).html(question_str);
        if (question.questionattrs != undefined && question.questionattrs != null) {
            var drag_attrs = question.questionattrs.split(";-;");
            for (var m=0; m<drag_attrs.length; m++) {
                drag_li_arr.push(drag_attrs[m]);
            }
        }
        var drag_input = create_element("span", null, "question_answer_" + question.id, "dragDrop_box", null, "innerHTML");
        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
            drag_input.innerHTML = answer_hash.get(question.id)[0];
        }
        $("#que_out_" + question.id).append(drag_input);        
    }
    var buttons_div = create_element("span", null, "save_button_" + question.id, "button_span", null, "innerHTML");
    buttons_div.innerHTML = "<input type='button' name='question_submit' class='save button_tk' onclick='javascript:generate_question_answer(\""
    + question.id +"\", \""+problem_id+"\", \"1\", 1);' value=''/>";
    buttons_div.innerHTML += "<input type='button' name='question_button' class='Uncertain button_tk' onclick='javascript:generate_que_unsure_answer(\""
    + question.id +"\", \""+problem_id+"\", \"0\", 1);' value=''/>";
    buttons_div.style.display = "none";
    $("#que_out_" + question.id).append(buttons_div);
    var answer_input = create_element("input", "answer_" + question.id, "answer_" + question.id, null, "hidden", "value");
    if (answer_hash != null && answer_hash.get(question.id) != null &&  answer_hash.get(question.id) != "") {
        answer_input.value = answer_hash.get(question.id)[0];
    }
    buttons_div.appendChild(answer_input);
}

//关闭select框
function close_select_ul(theEvent, obj, question_id){
    var browser=navigator.userAgent;
    if (browser.indexOf("MSIE")>0){
        if (obj.contains(event.toElement)) return;
    }else{        
        if (obj.contains(theEvent.relatedTarget)) return;
    }
    $("#select_ul_" + question_id).css("display", "none");
}

//显示select ul
function select_ul(question_id) {
    $('#select_ul_'+question_id).css("display", "block");
    show_que_save_button(question_id);
}

//根据li选择的单词填写答案
function select_li(li, question_id) {
    var li_value = $(li).html();
    if (li_value != null) {
        $("#question_attr_"+question_id).html(li_value);
        $("#select_ul_"+question_id).css("display", "none");
    }
}

//添加question所需div
function create_question(problem_id, question_id_input, parent_div, question, innerHTML, drag_li_arr) {
    $("#all_question_ids").attr("value", $("#all_question_ids").val() + question.id + ",");
    question_id_input.value += "" + question.id + ",";
    var que_out_div = create_element("div", null, "que_out_" + question.id, "question_area", null, "innerHTML");
    que_out_div.innerHTML = "<input type='hidden' name='question_type' id='question_type_"+ question.id
    +"' value='"+ question.correct_type +"'/>"
    + "<input type='hidden' name='question_sure' id='question_sure_"+ question.id + "' value='' />"
    + "<div class='area_left'>" + innerHTML + "</div>";
    parent_div.appendChild(que_out_div);
    var single_question_div = create_element("div", null, "single_question_" + question.id, "area_right", null, "innerHTML");
    if (question.description != undefined && question.description != null && question.description != "") {
        var final_description = replace_title_span(question.description, problem_id);
        single_question_div.innerHTML += "<div class='question_title'>" +
        final_description + "</div>";
    }
    que_out_div.appendChild(single_question_div);
    que_out_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    create_single_question(single_question_div, question, drag_li_arr);
    create_answer_area(single_question_div, question, problem_id);
}

//创建完型填空选词列表
function create_words_div(drop_div, problem_id, drag_li_arr) {
    if ($("#problem_title_" + problem_id).attr("id") != undefined) {
        var que_attrs = drag_li_arr.sort(function(){
            return Math.random()>0.5?-1:1;
        });
        var tip_div = create_element("div", null, "problem_drag_"+problem_id, "drag_tk_box border_radius", null, "innerHTML");
        drop_div.appendChild(tip_div);
        var drop_inner_div = create_element("div", null, null, "drag_tk border_radius", null, "innerHTML");
        tip_div.appendChild(drop_inner_div);
        var drop_ul = create_element("ul", null, null, null, null, "innerHTML");
        drop_inner_div.appendChild(drop_ul);
        for (var m=0; m<que_attrs.length; m++) {
            if (que_attrs[m] != null && que_attrs[m] != "") {
                var drag_attr = create_element("li", null, null, "", null, "innerHTML");
                drag_attr.innerHTML = que_attrs[m];
                drop_ul.appendChild(drag_attr);
                $(drag_attr).draggable({
                    helper: "clone"
                });
            }
        }
    }
}

//创建不同题型
function create_single_question(que_div, question, drag_li_arr) {
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        if (question.correct_type == "6") {
            var drag_div = create_element("div", null, null, "answer_text", null, "innerHTML");
            if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                que_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='width:"+ erea_with(answer_hash.get(question.id)[0])
                +";height:"+erea_height("20px;", answer_hash.get(question.id)[0])
                +";' onclick='javascript:show_que_save_button(\""+question.id+"\")'>"
                + answer_hash.get(question.id)[0] +"</textarea>";
            } else {
                que_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='height: 20px;' onclick='javascript:show_que_save_button(\""+question.id+"\")'></textarea>";
            }
            que_div.appendChild(drag_div);
        } else {
            var ul = create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
            que_div.appendChild(ul);
        }
        for (var i=0; i<que_attrs.length; i++) {
            if (que_attrs[i] != null && que_attrs[i] != "") {
                if (question.correct_type == "6") {
                    drag_li_arr.push(que_attrs[i]);
                }
                else {
                    var attr = create_element("li", null, null, null, null, "innerHTML");
                    ul.appendChild(attr);
                    if (question.correct_type == "0") {
                        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != ""
                            && $.trim(answer_hash.get(question.id)[0]) == $.trim(que_attrs[i])) {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\" checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />";
                        } else {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\" onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                    } else if (question.correct_type == "1") {
                        var has_answer = false;
                        if (answer_hash != null &&  answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                            var all_attr = answer_hash.get(question.id)[0].split(";|;");
                            if (all_attr != null && all_attr.length > 0) {
                                for (var a = 0; a<all_attr.length; a ++) {
                                    if ($.trim(all_attr[a]) == $.trim(que_attrs[i])) {
                                        has_answer = true;
                                    }
                                    if (has_answer) {
                                        break;
                                    }
                                }
                            }
                        }
                        if (has_answer) {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\" checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        } else {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\" onclick='javascript:show_que_save_button(\""+question.id+"\")'/>";
                        }
                    }
                    attr.innerHTML += "&nbsp;&nbsp;"+ que_attrs[i];
                }
            }
        }
    } else {
        if (question.correct_type == "2") {
            var attr1 = create_element("ul", null, null, "chooseQuestion", null, "innerHTML");
            que_div.appendChild(attr1);
            if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] == "1") {
                attr1.innerHTML = "<li><input type='radio' id='question_attr_1' name='question_attr_"+ question.id
                +"' value='1' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;</li>";
            } else {
                attr1.innerHTML = "<li><input type='radio' id='question_attr_1' name='question_attr_"+ question.id
                +"' value='1' onclick='javascript:show_que_save_button(\""+question.id+"\")' />对/是&nbsp;&nbsp;</li>";
            }

            if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] == "0") {
                attr1.innerHTML += "<li><input type='radio' id='question_attr_0' name='question_attr_"+ question.id
                +"' value='0' checked='true' onclick='javascript:show_que_save_button(\""+question.id+"\")' />错/否&nbsp;&nbsp;</li>";
            } else {
                attr1.innerHTML += "<li><input type='radio' id='question_attr_0' name='question_attr_"+ question.id
                +"' value='0' onclick='javascript:show_que_save_button(\""+question.id+"\")'/>错/否&nbsp;&nbsp;</li>";
            }
        }
        else {
            var answer_text = "";
            if (question.correct_type == "3") {
                if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                    answer_text = "<textarea cols='' rows='' class='answer_input'"
                    + " id='question_answer_"+ question.id +"' name='question_answer_"
                    + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
                    +"\", 1)' onblur='javascript:window.clearInterval(change_length);' style='width:"
                    + erea_with(answer_hash.get(question.id)[0]) +";height:"
                    + erea_height("20px;", answer_hash.get(question.id)[0]) +";'>"
                    + answer_hash.get(question.id)[0] +"</textarea>";
                }
                else {
                    answer_text = "<textarea cols='' rows='' class='answer_input' id='question_answer_"+ question.id
                    +"' name='question_answer_" + question.id +"' onfocus='javascript:start_change_length(\""+ question.id
                    +"\", 1)' onblur='javascript:window.clearInterval(change_length);' style='width:148px;height: 20px;'></textarea>";
                }
            }
            else {
                if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                    answer_text = "<textarea cols='' rows='' class='answer_textarea' id='question_answer_"+ question.id
                    +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'>"
                    + answer_hash.get(question.id)[0] +"</textarea>";
                } else {
                    answer_text = "<textarea cols='' rows='' class='answer_textarea' id='question_answer_"+ question.id
                    +"' name='question_answer_"+ question.id +"' onfocus='javascript:show_que_save_button(\""+question.id+"\")'></textarea>";
                }
            }
            que_div.innerHTML += answer_text;
        }
        
    }
}

//创建按钮已经答案区域
function create_answer_area(que_div, question, problem_id) {
    add_que_save_button(que_div, question.id, problem_id);
    var answer_input = create_element("input", "answer_" + question.id, "answer_" + question.id, null, "hidden", "value");
    if (answer_hash != null && answer_hash.get(question.id) != null &&  answer_hash.get(question.id) != "") {
        answer_input.value = answer_hash.get(question.id)[0];
    }
    que_div.appendChild(answer_input);
}

//创建input
function create_element(element, name, id, class_name, type, ele_flag) {
    var ele = document.createElement("" + element);
    if (name != null)
        ele.name = name;
    if (id != null)
        ele.id = id;
    if (class_name != null)
        ele.className = class_name;
    if (type != null)
        ele.type = type;
    if (ele_flag == "innerHTML") {
        ele.innerHTML = "";
    } else {
        ele.value = "";
    }
    return ele;
}

//显示考试倒计时
var exam_time_start = null;
function show_exam_time() {
    // 注意setInterval函数: 时间逝去100(毫秒)后, onTimer才开始执行
    if (start != 0) {
        exam_time_start = new Date();
        timer = self.setInterval(function(){
            onTimer();
        }, 100);
    }
}

// 倒计时函数
function onTimer() {
    var date_start = new Date();
    if (start <= 0) {
        window.onbeforeunload = null;
        window.clearInterval(timer);
        document.getElementById("paper_form").submit();
        setTimeout(function(){
            tishi_alert("答卷时间已到，请您停止答题，系统已经自动帮您交卷");
        }, 100);
        return;
    } else if (start == 300) {
        setTimeout(function(){
            tishi_alert("还剩5分钟答题时间，请您尽快答题并交卷");
        }, 100);
    }
    var current_time = start;

    var m = Math.floor((current_time%3600)/60);
    var h = Math.floor(current_time/3600);
    var sm = m < 10 ? ("0" + m) : m;
    var sh = h < 10 ? ("0" + h) : h;

    $("#exam_time").html("剩余时间  " + sh + ":" + sm);
    $("#true_exam_time").html(start);

    colse_or_open_block(current_time);
    if (start%150 == 0) {
        get_sever_time();
    }
    var date_end = new Date();
    if (start != 0) {
        if ((date_end - exam_time_start) > 500 && (date_end - exam_time_start) < 5000) {
            start = Math.round((start - (date_end - exam_time_start)/1000)*10)/10;
        } else {
            start = Math.round((start - 0.1 - (date_end - date_start)/1000)*10)/10;
        }
    }
    exam_time_start = date_end;
}

//打开模块和关闭答案
function colse_or_open_block(current_time) {
    if (is_fix_time) {
        var has_close_block = false;
        var block_ids = $("#block_ids").val().split(",");
        for (var i=0; i<block_ids.length; i++) {
            if (block_end_hash.get(block_ids[i]) != null && block_end_hash.get(block_ids[i]) != "") {
                var block_title = $("#b_title_" + block_ids[i]).html();
                var block_time = return_giving_time(block_end_hash.get(block_ids[i]));
                if (block_time == current_time || (block_time > current_time && $("#block_" + block_ids[i]).css("display") != "none")) {
                    var flash_div = create_element("div", null, "flash_notice", "tishi_tab0 border_radius", null, "innerHTML");
                    flash_div.innerHTML = "<span span class='xx_x' onclick='javascript:flash_remove(this);'><img src='/assets/xx.png'/></span>"
                    + "<p>" +block_title + " 部分答题时间已到，您的答案将自动被提交，请您继续做其它部分的题。 </p>";
                    document.body.appendChild(flash_div);
                    show_flash_not_close();
                    window.clearInterval(local_timer);
                    local_storage_answer("open");
                    has_close_block = true;
                    break;
                } else if (Math.floor(current_time - block_time) == 60) {
                    tishi_alert("当前 "+block_title+" 部分剩余答题时间为1分钟，请您尽快答题，并提交答案。");
                }
            }
        }
        if (has_close_block) {
            var has_next_block = false;
            for (var j=0; j<block_ids.length; j++) {
                if (block_start_hash.get(block_ids[j]) != null) {
                    if (return_giving_time(block_start_hash.get(block_ids[j])) == current_time) {
                        open_nav(block_ids[j]);
                        has_next_block = true;
                        break;
                    }
                }
            }
            if (has_next_block == false) {
                for (var k=0; k<block_ids.length; k++) {
                    if (block_start_hash.get(block_ids[k]) != null && block_start_hash.get(block_ids[k]) != "") {
                        if (block_start_hash.get(block_ids[k]) == ""
                            || (return_giving_time(block_start_hash.get(block_ids[k])) >= current_time &&
                                (block_end_hash.get(block_ids[k]) == "" ||
                                    return_giving_time(block_end_hash.get(block_ids[k])) < current_time))) {
                            open_nav(block_ids[k]);
                            break;
                        }
                    }
                }
            }
        }
    }
}

//用来5分钟存储的定时器
var local_save_time = null;
function local_save_start() {
    local_save_time = new Date();
    local_timer = self.setInterval(function(){
        local_save();
    }, 100);
}

//5分钟存储函数
function local_save() {
    var start_date = new Date();
    if (local_start_time <= 0) {
        window.clearInterval(local_timer);
        local_storage_answer("open");
        return;
    }

    var end_date = new Date();
    if ((end_date - local_save_time) > 500 && (end_date - local_save_time) < 5000) {
        local_start_time = Math.round((local_start_time - (end_date - local_save_time)/1000)*10)/10;
    } else {
        local_start_time = Math.round((local_start_time - 0.1 - (end_date - start_date)/1000)*10)/10;
    }
    local_save_time = end_date;
}

//用来1分钟取一下服务器时间
function get_sever_time() {
    var examination_id = $("#examination_id").val();
    var user_id = $("#user_id").val();
    $.ajax({
        async:true,
        complete:function(request){
            if ($("#true_exam_time").html() == "不限时") {
                start = 0;
                $("#exam_time").html("不限时");
            }
            else {
                start = Math.round(new Number(request.responseText)*10)/10;
                var h = Math.floor(start/3600) < 10 ? ("0" + Math.floor(start/3600)) : Math.floor(start/3600);
                var m = Math.floor((start%3600)/60) < 10 ? ("0" + Math.floor((start%3600)/60)) : Math.floor((start%3600)/60);
                $("#exam_time").html("剩余时间  " + h + ":" + m);
            }
        },
        data:{
            user_id :user_id
        },
        dataType:'script',
        url:"/simulations/"+ examination_id +"/get_exam_time",
        type:'post'
    });
    return false;
}

//用来判断获取数据的类型
function tof(val) {
    var t;
    switch(val) {
        case null:
            t = "null";
            break;
        case undefined:
            t = "undefined";
            break;
        default:
            t = Object.prototype.toString.call(val).match(/object\s(\w+)/)[1];
            break;
    }
    return  t.toLowerCase();
}

//用来返回题目中所有的提点是否已经回答
function is_problem_answer(problem_id, is_nomal) {
    var answer_flag = "";
    var question_ids = $("#question_ids_" + problem_id).val();
    if (question_ids != "") {
        var ids = question_ids.split(",");
        var is_answer_num = 0;
        for (var i=0; i<ids.length-1; i++) {
            var question_div = $("#que_out_" + ids[i]);
            if (question_div.attr("id") != undefined) {
                var is_answer = question_value(ids[i], is_nomal);
                if (is_answer) {
                    is_answer_num++ ;
                }
            }
        }
        if (is_answer_num != 0) {
            if (is_answer_num == (ids.length-1)) {
                answer_flag = "all";
            } else {
                answer_flag = "href";
            }
        } else {
            answer_flag = "none";
        }
    }
    if (answer_flag == "all") {
        $("#is_answer_" + problem_id).attr("value", "1");
    } else {
        $("#is_answer_" + problem_id).attr("value", "");
    }
    return answer_flag;
}

//用来返回提点是否已经回答
function generate_question_answer(question_id, problem_id, is_sure, is_nomal) {
    $("#question_sure_" + question_id).attr("value", is_sure);
    question_color(question_id, is_nomal);
    is_problem_answer(problem_id, is_nomal);
    save_question(question_id, is_sure);
    alreay_answer_que_num();
    $("#save_button_" + question_id).css("display", "none");
}

//使用本地存储保存提点内容
function save_question(question_id, is_sure) {
    var paper_id = $("#paper_id").val();
    var examination_id = $("#examination_id").val();
    var answer = $("#answer_" + question_id);
    if(window.openDatabase){
        if (answer.val() != null && answer.val() != undefined && !checkspace(answer.val())) {
            remove_answer(question_id, getCookie('user_id'), paper_id, examination_id);
            add_answer(question_id, getCookie('user_id'), paper_id, examination_id, answer.val(), is_sure);

        }
    }
}

//提点颜色
function question_color(question_id, is_nomal) {
    if (is_nomal == 0) {
        if ($("#question_sure_"+question_id).val() == "1") {
            $("#que_out_" + question_id).removeClass("q_no").addClass("q_yes");
            $("#a_que_nav_" + question_id).removeClass("pink").addClass("lvse");
        } else {
            $("#que_out_" + question_id).removeClass("q_yes").addClass("q_no");
            $("#a_que_nav_" + question_id).removeClass("lvse").addClass("pink");
        }
    } else {
        if ($("#question_sure_"+question_id).val() == "1") {

            if ($("#que_out_" + question_id + " .dragDrop_box").attr("id") != undefined) {
                $("#que_out_" + question_id + " .dragDrop_box").removeClass("q_no").addClass("q_yes");
            } else if ($("#que_out_" + question_id + " textarea").attr("id") != undefined) {
                $("#que_out_" + question_id + " textarea").removeClass("q_no").addClass("q_yes");
            } else if ($("#que_out_" + question_id + " .select_span").attr("id") != undefined) {
                $("#que_out_" + question_id + " .select_span").removeClass("q_no").addClass("q_yes");
            } else if ($("#que_out_" + question_id + " .input_tk").attr("id") != undefined) {
                $("#que_out_" + question_id + " .input_tk").removeClass("q_no").addClass("q_yes");
            }
            $("#a_que_nav_" + question_id).removeClass("pink").addClass("lvse");
        } else {
            if ($("#que_out_" + question_id + " .dragDrop_box").attr("id") != undefined) {
                $("#que_out_" + question_id + " .dragDrop_box").removeClass("q_yes").addClass("q_no");
            } else if ($("#que_out_" + question_id + " .select_span").attr("id") != undefined) {
                $("#que_out_" + question_id + " .select_span").removeClass("q_yes").addClass("q_no");
            } else if ($("#que_out_" + question_id + " textarea").attr("id") != undefined) {
                $("#que_out_" + question_id + " textarea").removeClass("q_yes").addClass("q_no");
            } else if ($("#que_out_" + question_id + " .input_tk").attr("id") != undefined) {
                $("#que_out_" + question_id + " .input_tk").removeClass("q_yes").addClass("q_no");
            }
            $("#a_que_nav_" + question_id).removeClass("lvse").addClass("pink");
        }
    }
    
}

function generate_que_unsure_answer(question_id, problem_id, is_sure, is_nomal) {
    generate_question_answer(question_id, problem_id, is_sure, is_nomal);
}

//返回提点是否确定，以及颜色
function load_un_sure_question(problem_id, is_nomal) {
    var question_ids = $("#question_ids_" + problem_id).val();
    if (question_ids != "") {
        var ids = question_ids.split(",");
        for (var i=0; i<ids.length-1; i++) {
            if (answer_hash != null && answer_hash.get(ids[i]) != null && answer_hash.get(ids[i]) != "") {
                if(parseInt(answer_hash.get(ids[i])[1]) == 1){
                    $("#question_sure_" + ids[i]).attr("value", "1");
                } else {
                    $("#question_sure_" + ids[i]).attr("value", "0");
                }
                question_color(ids[i], is_nomal);
            }
        }
    }
}

//用来返回每个提点是否已经回答
function question_value(question_id, is_nomal) {
    var is_answer = false;
    $("#answer_" + question_id).attr("value", "");
    var correct_type = $("#question_type_" + question_id).val();
    if (correct_type == "0" || correct_type == "1" || correct_type == "2") {
        var attr = document.getElementsByName("question_attr_" + question_id);
        if (attr != null) {
            if (is_nomal == 1) {
                if (correct_type == "0") {
                    if (attr[0].innerHTML != null && attr[0].innerHTML != "-1") {
                        $("#answer_" + question_id).attr("value", attr[0].innerHTML);
                    }
                } else if (correct_type == "1") {
                    $("#answer_" + question_id).attr("value", $("#question_answer_" + question_id).html());
                }
            }else {
                for (var i=0; i<attr.length; i++) {
                    if (attr[i].checked == true) {
                        if ($("#answer_" + question_id).val() == "") {
                            $("#answer_" + question_id).attr("value", attr[i].value);
                        } else {
                            $("#answer_" + question_id).attr("value", $("#answer_" + question_id).val() + ";|;" + attr[i].value);
                        }
                        is_answer = true;
                    }
                }
            }  
        }
    } else if (correct_type == "3" || correct_type == "5" || correct_type == "6") {
        var answer = $("#question_answer_" + question_id);
        if (answer.val() != null && answer.val() != undefined && !checkspace(answer.val())) {
            is_answer = true;
            $("#answer_" + question_id).attr("value", answer.val());
        } else if (answer.html() != null && answer.html() != undefined && !checkspace(answer.html())) {
            is_answer = true;
            $("#answer_" + question_id).attr("value", answer.html());
        }
    }
    return is_answer;
}

//用来返回考生已经答完多少道题点
function alreay_answer_que_num() {
    var total_num = 0;
    var problem_ids = $("#problem_ids").val();
    if (problem_ids != null && problem_ids != "") {
        var ids_arr = problem_ids.split(",");
        for (var i=0; i<ids_arr.length; i++) {
            var question_ids = $("#question_ids_" + ids_arr[i]).val();
            if (question_ids != null && question_ids != undefined && question_ids != "") {
                var q_ids = question_ids.split(",");
                for (var j=0; j<q_ids.length-1; j++) {
                    var question_answer = $("#answer_" + q_ids[j]).val();
                    if (question_answer != null && question_answer != undefined && question_answer != "") {
                        total_num ++;
                    }
                }
            }
        }
        $("#leaving_num").html(papers.paper.total_num - total_num);
    }
}

//提交试卷之前判断试卷是否已经全部答完
function generate_result_paper(paper_id) {
    window.onbeforeunload = null;
    var flag = true;
    //var all_question_ids = $("all_question_ids").value;
    var all_problem_ids = $("#problem_ids").val();
    if (all_problem_ids != null && all_problem_ids != "") {
        var problem_ids = all_problem_ids.split(",");
        var answer_length = 0;
        for (var i=0; i<problem_ids.length-1; i++) {
            var is_answer = $("#is_answer_" + problem_ids[i]);
            if (is_answer != null && is_answer.value != null) {
                if (is_answer.val() == "1") {
                    answer_length++ ;
                }
            }
        }
        if (answer_length < (problem_ids.length-1)) {
            if(!confirm('您还有题尚未答完，确定要交卷么?')) {
                flag = false;
            }
        } else {
            if(!confirm('您已经答完所有题，确定要交卷么?')) {
                flag = false;
            }
        }
    }
    return flag;
}

function local_storage_answer(flag) {
    var all_question_ids = $("#all_question_ids").val();
    if (all_question_ids != null && all_question_ids != "") {
        var question_ids = all_question_ids.split(",");
        if (question_ids.length != 0) {
            var arr = new Array();
            for (var j=0; j<question_ids.length; j++) {
                var ans = $("#answer_" + question_ids[j]).val();
                if (ans != null && ans != undefined && ans != "") {
                    arr.push(question_ids[j]);
                    arr.push(ans);
                    arr.push($("#question_sure_" + question_ids[j]).val());
                }
            }
            add_to_db(arr, flag);
        }
    }
}

//每隔5分钟自动存储答卷内容
function add_to_db(arr, flag) {
    var examination_id = $("#examination_id").val();
    $.ajax({
        async:true,
        complete:function(request){
            if (flag == "open") {
                reload_local_save();
            } else {
                window.close();
            }
        },
        data:{
            arr :arr.join(",")
        },
        dataType:'script',
        url:"/simulations/"+ examination_id +"/five_min_save",
        type:'post'
    });
    return false;
}

//重新执行5分钟倒计时
function reload_local_save() {
    local_start_time = 300;
    local_save_start();
}

//load用户已经答完的答案
function load_answer(paper_id, examination_id) {
    if(window.openDatabase){
        load_local_save(paper_id, examination_id);
    } else {
        read_answer_xml();
    }
}

function read_answer_xml() {
    if (answer_hash == null) {
        answer_xml();
    }
}

//load本地存储的答案
function load_local_save(paper_id, examination_id) {
    if (paper_id != "" && examination_id != "" && getCookie('user_id') != "") {
        list_answer(getCookie('user_id'), paper_id, examination_id);
    }
}

//loadxml文件
function loadxml(xmlFile) {
    var xmlDoc;
    try {
        if(window.ActiveXObject) {
            xmlDoc = new ActiveXObject('MSXML2.DOMDocument');
            xmlDoc.async = false;
            xmlDoc.load(xmlFile);
        }
        else if (document.implementation&&document.implementation.createDocument) {
            var xmlhttp = new window.XMLHttpRequest();
            xmlhttp.open("GET", xmlFile, false);
            xmlhttp.send(null);
            xmlDoc = xmlhttp.responseXML;
        }else{
            return null;
        }
        return xmlDoc;
    } catch (e) {
        tishi_alert("您的浏览器安全级别设置过高，屏蔽了一些功能，请您重新设置您的浏览器安全级别。")
        return null;
    }

}

//load答案的xml文件
function answer_xml() {
    var answer_url = $("#answer_url").val();
    var xmlDom = loadxml(answer_url+"?"+Math.random());
    if (xmlDom != null) {
        var questions = xmlDom.getElementsByTagName("question");
        if (questions.length > 0) {
            answer_hash = new Hashtable();
            for(var i=0;i<questions.length;i++){
                var answer = "";
                if (questions[i].getElementsByTagName("answer")[0].firstChild != null) {
                    answer = questions[i].getElementsByTagName("answer")[0].firstChild.data;
                }
                answer_hash.put(questions[i].getAttribute("id"), [answer, questions[i].getAttribute("is_sure")]);
            }
        }
    }
}

//记录当前模块是否有听力
function is_has_audio(block_id, description) {
    var titles = description.split("((mp3))");
    if (titles.length == 1) {
        titles = description.split("<mp3>");
    }
    var final_title = "";
    if (titles.length > 1) {
        mp3_url = titles[1];
        var audio_str = "";
        if (is_fix_time) {
            audio_str = "<div id='jquery_jplayer_"+ block_id +"' class='jp-jplayer' style='width:0px;height:1px;'></div>";
        } else {
            audio_str = generate_jplayer_div(block_id);
        }
        final_title = titles[0] + audio_str;
    } else {
        final_title = description;
    }
    return final_title;
}

function generate_jplayer_div(block_id) {
    var final_title = "<div id='jquery_jplayer_" + block_id + "' class='jp-jplayer'></div><div id='jp_container_1'"
    + 'class="jp-audio"><div class="jp-type-playlist"><div class="jp-gui jp-interface">'
    + '<ul class="jp-controls"><li><a href="javascript:;" class="jp-play" tabindex="1">play</a></li>'
    + '<li><a href="javascript:;" class="jp-pause" tabindex="1">pause</a></li>'
    + '<li><a href="javascript:;" class="jp-stop" tabindex="1">stop</a></li>'
    + '<li><a href="javascript:;" class="jp-mute" tabindex="1" title="mute">mute</a></li>'
    + '<li><a href="javascript:;" class="jp-unmute" tabindex="1" title="unmute">unmute</a></li>'
    + '</ul> <div class="jp-progress"><div class="jp-seek-bar"><div class="jp-play-bar"></div> </div></div>'
    + '<div class="jp-volume-bar"><div class="jp-volume-bar-value"></div> </div>'
    + '<div class="jp-time-holder"><div class="jp-current-time"></div><div class="jp-duration"></div></div>'
    + '</div><div class="jp-playlist" style="display:none;"><ul><li></li></ul></div><div class="jp-no-solution">'
    + '<span>Update Required</span>To play the media you will need to either update your browser to a recent' 
    + 'version or update your <a href="http://get.adobe.com/flashplayer/" target="_blank">Flash plugin</a>.</div> </div></div>';
    return final_title;
}

function generate_jplayer(mp3_url, block_id) {
    (function(){
        new jPlayerPlaylist({
            jPlayer: "#jquery_jplayer_"+block_id,
            cssSelectorAncestor: "#jp_container_1"
        },
        mp3_url
        , {
            swfPath: "js",
            supplied: "oga, mp3",
            wmode: "window"
        });
    //        var back_server_path = $("#back_server_url").val();
    //        jQuery("#jquery_jplayer_"+block_id).jPlayer({
    //            ready: function() {
    //                jQuery(this).jPlayer("setMedia", {
    //                    mp3:""+back_server_path + mp3_url
    //                });
    //            },
    //            ended: function(){
    //                add_audio_cookies(block_id);
    //            },
    //            swfPath: "/assets/jplayer",
    //            supplied: "mp3",
    //            wmode: "window"
    //        });
    })(jQuery)    
}

//替换问题中隐藏的span，变为可拖动
function replace_title_span(title, problem_id) {
    var final_title = "";
    if (title.indexOf("problem_x_dropplace") > 0) {
        final_title = title.replace(/problem_x/g, "problem_" + problem_id);
    } else {
        final_title = title;
    }
    return final_title;
}

//将隐藏的span变成可拖拽的
function store_title_span(problem_id, question_id) {
    var str = document.getElementById("question_" + problem_id).innerHTML;
    var place_num = 1;
    while(str.indexOf("problem_" + problem_id + "_dropplace_" + place_num) >= 0){
        var store_id = "problem_" + problem_id + "_dropplace_" + place_num;
        $(store_id).style.cursor = 'Move';
        $(store_id).className = "task_span";
        Droppables.add(store_id, {
            onDrop:function(element,store_id){
                $(store_id).innerHTML = element.innerHTML;
                $(store_id).style.color = "#96AE89";
                show_que_save_button(question_id);
            }
        })
        place_num ++;
    }
    if (answer_hash != null &&  answer_hash.get(question_id) != null && answer_hash.get(question_id)[0] != null) {
        var answers = [];
        answers = answer_hash.get(question_id)[0].split(";|;");
        for (var i=1; i<=place_num; i++) {
            if (answers[i-1] != null && answers[i-1] != "") {
                $("problem_" + problem_id + "_dropplace_" + i).innerHTML =  answers[i-1];
                $("problem_" + problem_id + "_dropplace_" + i).style.color = "#96AE89";
            }
        }
    }

}

//当打开的模块有音频时，播放有音频
function start_block_audio(block_id) {
    if ($("#jquery_jplayer_" + block_id).attr("id") != undefined) {
        if (getCookie("exam_audio_" + block_id) == null || new Number(getCookie("exam_audio_" + block_id)) == 0) {
            tishi_alert("您当前打开的模块为听力模块，请做好答题准备播放听力。");
            setTimeout(function(){
                control_media(block_id);
            }, 5000);
        } else {
            tishi_alert("听力播放结束，请抓紧时间答题。");
        }
    }
}

//控制音频内容
var remember_time_flag = 0;
function control_media(audio_id) {
    try {
        var audio = $("#jquery_jplayer_"+audio_id);
        if (getCookie("audio_time_" + audio_id) != "end") {
            if(getCookie("exam_audio_" + audio_id) == null){
                setCookie("exam_audio_" + audio_id, 0);
            }
            if(new Number(getCookie("exam_audio_" + audio_id)) < 1){
                //                if (getCookie("audio_time_" + audio_id) != null) {
                //                    audio.jPlayer("play", parseFloat(getCookie("audio_time_" + audio_id)));
                //                } else {
                //                    audio.jPlayer("play", 0);
                //                }
                audio.bind(jQuery.jPlayer.event.timeupdate, function(event) {
                    if (event.jPlayer.status.currentTime != null) {
                        setCookie("audio_time_" + audio_id, event.jPlayer.status.currentTime);
                    }
                    if (remember_time_flag == 0) {
                        remember_time_flag = 1;
                        if (block_end_hash.get(audio_id) != null && block_end_hash.get(audio_id) != "") {
                            var time = return_giving_time(block_start_hash.get(audio_id)) - return_giving_time(block_end_hash.get(audio_id));
                            if (time < parseFloat(event.jPlayer.status.duration)) {
                                var total_time = return_giving_time(block_end_hash.get(audio_id)) + time
                                - Math.ceil(parseFloat(event.jPlayer.status.duration)) ;
                                block_end_hash.put(audio_id,
                                    (Math.floor(total_time/3600) + ":" + Math.floor(total_time%3600/60) + ":" + total_time%3600%60));
                                var block_ids = $("block_ids").value.split(",");
                                var next_block_id = "" + block_ids[block_ids.indexOf(audio_id) + 1];
                                if (block_start_hash.get(next_block_id) != null){
                                    var next_start_time = return_giving_time(block_start_hash.get(next_block_id))
                                    - (Math.ceil(parseFloat(event.jPlayer.status.duration)) - time);
                                    block_start_hash.put(next_block_id,
                                        (Math.floor(next_start_time/3600) + ":" + Math.floor(next_start_time%3600/60) + ":" + next_start_time%3600%60));
                                }

                            }
                        }
                    }
                });

            }
        }
    }
    catch (e) {
        tishi_alert("音频文件不能播放，请您检查您的音频文件是否存在。");
    }
}

//记录听力已经播放
function add_audio_cookies(audio_id) {
    if (getCookie("exam_audio_" + audio_id) != null) {
        setCookie("exam_audio_" + audio_id, new Number(getCookie("exam_audio_" + audio_id))+1);
        setCookie("audio_time_" + audio_id, "end");
        tishi_alert("听力播放结束，请抓紧时间答题。")
    }
}

//更改文本域的长度
function start_change_length(id, flag) {
    show_que_save_button(id);
    change_length = self.setInterval("call_me(75, " + id + ", "+ flag +")", 1);
}

//根据字符长度改变文本域的长和宽
function call_me(max_length, id, flag) {
    if(($("#question_answer_" + id).val() != null ) || ($("#question_answer_" + id).val() != "" )) {
        if(($("#question_answer_" + id).val().length >= 15) && ($("#question_answer_" + id).val().length < max_length)) {
            $("#question_answer_" + id).css("width", $("#question_answer_" + id).val().length*8 + "px");
        } else if ($("#question_answer_" + id).val().length == max_length) {
            $("#question_answer_" + id).css("width", max_length*8 + "px");
        } else if ($("#question_answer_" + id).val().length >= max_length) {
            $("#question_answer_" + id).css("width", 610 + "px");
            if (flag == 1) {
                if (new Number($("#question_answer_" + id).css("height").split("px")[0]) >= 120) {
                    $("question_answer_" + id).css("height", "120px");
                } else if ($("#question_answer_" + id).val().length > 75 && $("#question_answer_" + id).val().length < 150
                    && $("#question_answer_" + id).css("height") == "20px") {
                    $("#question_answer_" + id).css("height", 48 + "px");
                } else if ($("#question_answer_" + id).val().length > 150 && $("#question_answer_" + id).val().length%60 == 0
                    && $("#question_answer_" + id).css("height") != "20px") {
                    $("#question_answer_" + id).css("height", 24*($("#question_answer_" + id).val().length/60 + 1) + "px");
                
                }
            }
            
        }
    }
}

//返回文本框宽度
function erea_with(str) {
    var width = "";
    if (str.length > 20 && str.length <= 48) {
        width = (str.length * 8) + "px";
    }else if (str.length > 48) {
        width = "610px";
        
    }
    return width;
}

//返回文本框高度
function erea_height(h, str) {
    var height = h;
    if (str.length > 80) {
        height = (20 * (str.length/70 + 1)) + "px";
    }
    return height;
}

//退出考试
function out_exam() {
    window.onbeforeunload = null;
    local_storage_answer("close");
}


function fix_top(last_top, element_id){
    var body_scrollTop = document.body.scrollTop|document.documentElement.scrollTop;  
    if(parseInt($("#" + element_id).get(0).offsetTop-body_scrollTop)<0){
        $("#" + element_id).get(0).style.position="fixed";
        $("#" + element_id).get(0).style.top="38px";
    }    
    if(body_scrollTop < fix_div_top.get(element_id) || body_scrollTop > last_top){
        $("#" + element_id).get(0).style.position="";
        $("#" + element_id).get(0).style.top="";
    }
}
