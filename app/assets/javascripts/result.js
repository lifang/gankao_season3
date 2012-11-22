//加载试卷
function load_paper() {
    //load已有的答案
    answer_xml();
    load_true_answer();
    setTimeout(function(){
        create_paper();
    }, 500);
}

//加载正确答案
function load_true_answer() {
    if (answer.paper.problems != undefined && answer.paper.problems.problem != undefined) {
        true_answers = new Hashtable();
        var problems = answer.paper.problems.problem;
        if (tof(problems) == "array") {
            for (var i=0; i<problems.length; i++) {
                load_true_answer_stp2(problems[i]);
            }
        } else {
            load_true_answer_stp2(problems);
        }
    }
}

//加载正确答案
function load_true_answer_stp2(problem) {
    if (problem.question != undefined) {
        var questions = problem.question;
        if (tof(questions) == "array") {
            for (var j=0; j<questions.length; j++) {
                true_answers.put(questions[j].id, [questions[j].answer, questions[j].analysis]);
            }
        } else {
            true_answers.put(questions.id, [questions.answer, questions.analysis]);
        }
    }
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
                create_block(bocks_div, blocks[i], i);
            }
        } else {
            create_block(bocks_div, blocks, 0);
        }
        next_last_index();
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
var mp3_url = [];
function create_block(bocks_div, block, index) {
    var block_title = block.base_info.title;
    var block_div = create_element("div", null, "block_" + block.id, "tp_left", null, "innerHTML");
    bocks_div.append(block_div);
    var part_message = create_element("div", null, "block_show", "part_head border_radius", null, "innerHTML");
    var block_str = block_title;
    if (block.time != null && block.time != "" && block.time != "0") {
        block_str += " (<span id='b_timer_"+ block.id +"'>"+ block.time +"</span> minutes)";
    }
    part_message.innerHTML = "<h1 id='b_title_"+ block.id +"'>" + block_str + "</h1>";
    //此处的增加和注释掉是为了真题的模考模式解决音频听力问题
    if (block_str.match("Listening") != null)  {
        part_message.innerHTML += "<p>" + generate_jplayer_div(block.id) + "</p>";
    }
    /*if (block.base_info.description != null && block.base_info.description != "") {
        part_message.innerHTML += "<p>" + is_has_audio(block.id, block.base_info.description) + "</p>";
    }*/
    block_div.appendChild(part_message);
    //试卷导航展开部分
    var navigation_div = $("#paper_navigation");
    var block_nav_div = create_element("div", null, "block_nav_"+block.id, "first_title", null, "innerHTML");
    block_nav_div.innerHTML = "<p onclick='javascript:open_nav(\""+block.id+"\");'>"+ block_title + "</p>";
    navigation_div.append(block_nav_div);
    var ul = create_element("ul", null, "nav_block_" + block.id, "second_menu", null, "innerHTML");
    if (index == 0) {
        block_div.style.display = "block";
        ul.style.display = "block";
        block_nav_div.className = "first_title highLight";
    } else {
        block_div.style.display = "none";
        ul.style.display = "none";
    }
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
                    var next_block_id = "";
                    var last_block_id = "";
                    if (block_ids.indexOf(block_ids[i]) == 0) {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:open_nav(\""+ next_block_id +"\");'>下一部分</a>";
                    } else if (block_ids.indexOf(block_ids[i]) == block_ids.length - 1) {
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:open_nav(\""+ last_block_id +"\");'>上一部分</a>";
                    } else {
                        next_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) + 1];
                        last_block_id = "" + block_ids[block_ids.indexOf(block_ids[i]) - 1];
                        next_div.innerHTML = "<a href='javascript:void(0);' class='tp_down_btn' onclick='javascript:open_nav(\""
                        + next_block_id +"\");'>下一部分</a><a href='javascript:void(0);' class='tp_up_btn' onclick='javascript:open_nav(\""
                        + last_block_id +"\");'>上一部分</a>";
                    }
                    $("#block_" + block_ids[i]).append(next_div);
                }
            }
        }
    }
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

//生成试卷提点导航
function create_question_navigation(block_nav_div, question, problem_id) {
    var class_name = "pink";
    var is_right = "X";
    if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] != null
        && answer_hash.get(question.id)[0] != ""
        && $.trim(answer_hash.get(question.id)[0]) == $.trim(true_answers.get(question.id)[0])) {
        // parseFloat(answer_hash.get(question.id)[1]) == parseFloat(question.score) 分数判断在此不再适用
        class_name = "lvse";
        is_right = "√";
    }
    var question_nav_li = create_element("li", null, "question_nav_"+question.id, null, null, "innerHTML");
    question_nav_li.innerHTML = "<a href='javascript:void(0);' class='"+ class_name +"' id='a_que_nav_"+ question.id
    +"' onclick='javascript:get_question_height(\""+question.id+"\", \""+problem_id+"\");'>"+ is_right +"</a>";
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
            var complete_title = problem.title;
            var back_server_path = $("#back_server_url").val();
            if (complete_title.split("((mp3))").length > 1) {
                //为了解决真题的模考模式每道听力都有音频的
                mp3_url.push({
                    mp3 : ""+back_server_path+complete_title.split("((mp3))")[1]
                });
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
        if (problem.question_type == "0" || problem.question_type == null || problem.question_type == undefined) {
            if (problem.questions != undefined && problem.questions.question != undefined) {
                var questions = problem.questions.question;
                if (tof(questions) == "array") {
                    for (var j=0; j<questions.length; j++) {
                        create_question_navigation(block_nav_div, questions[j], problem.id);
                        create_question(problem, question_id_input, problem_div, questions[j], question_num, drag_li_arr);
                        question_num ++ ;
                    }
                } else {
                    create_question_navigation(block_nav_div, questions, problem.id);
                    create_question(problem, question_id_input, problem_div, questions, question_num, drag_li_arr);
                    question_num ++ ;
                }
            }
            problem_div.appendChild(create_problem_json(problem, block_id));
        } else {
            drag_problem(out_que_div, problem, block_nav_div, drag_li_arr, question_id_input, block_id);
        }
        if (drag_li_arr.length > 0) {
            if (drop_div != null) {
                create_words_div(drop_div, problem.id, drag_li_arr);
            }
        } else {
            $(drop_div).remove();
        }
        $("#problem_ids").attr("value",  $("#problem_ids").val() + "" + problem.id + ",");
    }
}

function drag_problem(title_div, problem, block_nav_div, drag_li_arr, question_id_input, block_id) {
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
                    create_question_navigation(block_nav_div, questions[j], problem.id);
                    create_drag_question(problem, question_id_input, questions[j], drag_li_arr);
                    question_num ++ ;
                    new_title = title_div.innerHTML;
                }
            }
        } else {
            if (new_title.indexOf("((sign))") > -1) {
                rep_str = "<span class='span_tk' id='que_out_"+ questions.id +"'></span>";
                new_title = new_title.replace(/\(\(sign\)\)/, rep_str);
                title_div.innerHTML = new_title;
                create_question_navigation(block_nav_div, questions, problem.id);
                create_drag_question(problem, question_id_input, questions, drag_li_arr);
                question_num ++ ;
                new_title = title_div.innerHTML;
            }
        }
    }
    title_div.appendChild(create_problem_json(problem, block_id));
}

//隐藏problem的json
function create_problem_json(problem, block_id) {
    var problem_json = create_element("input", null, "p_json_"+problem.id, null, "hidden", "value");
    var json_arr = JSON.stringify(problem).split(",");
    if ($("#jquery_jplayer_" + block_id).attr("id") !== undefined) {
        if (problem.title.indexOf("((mp3))") == -1) {
            var new_title = json_arr[3].split("\"title\":\"");
            if (new_title[1] != null) {
                json_arr[3] = new_title[0] + "\"title\":\"((mp3))" + mp3_url + "((mp3))" + new_title[1];
            }
        }
    }
    problem_json.value = "" + json_arr.join(",");
    return problem_json;
}

//创建可拖动的div
function create_drag_question(problem, question_id_input, question, drag_li_arr) {
    question_id_input.value += "" + question.id + ",";
    var question_str = "";
    var bk_color = "correctWrong_bg";
    if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] != null
        && answer_hash.get(question.id)[0] != ""
        && $.trim(answer_hash.get(question.id)[0]) == $.trim(true_answers.get(question.id)[0])) {
        // parseFloat(answer_hash.get(question.id)[1]) == parseFloat(question.score) 用分数在此判断不再适用
        bk_color = "correctRight_bg";
    }
    var answer = "";
    if (true_answers.get(question.id) != null && true_answers.get(question.id)[0] != null) {
        answer = true_answers.get(question.id)[0];
    }
    question_str += "<input type='hidden' id='q_answer_"+ question.id +"' value=\""+ answer +"\" />";
    var analysis = (true_answers.get(question.id) != null && true_answers.get(question.id)[1] != null)
    ? true_answers.get(question.id)[1] : "";
    question_str += "<div id='q_analysis_"+ question.id +"' style='display:none;'>"+ analysis +"</div>";
    var user_answer = (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "")
    ? answer_hash.get(question.id)[0] : "";
    question_str += "<input type='hidden' id='u_answer_"+ question.id +"' value='"+ user_answer +"' />";
    if ((parseFloat(question.correct_type) == 0) || (parseFloat(question.correct_type) == 2)) {
        if (question.questionattrs != undefined && question.questionattrs != null) {
            question_str += "<span class='select_span "+ bk_color +"' name='question_attr_"+ question.id +"' id='question_attr_"
            + question.id +"' onclick=\"javascript:show_select("
            + problem.id +", '"+ question.id +"', '"+ question.correct_type +"', '"
            + problem.question_type +"')\">" + user_answer +"</span>";
            var que_attrs = question.questionattrs.split(";-;");
            question_str += "<span class='select_ul' id='select_ul_"+ question.id
            +"' onmouseover=\"javascript:$('#select_ul_"+ question.id
            +"').css('display','');\" onmouseout=\"javascript:$('#select_ul_"+ question.id
            +"').css('display','none');\" style='display:none;'>";
            for (var i=0; i<que_attrs.length; i++) {
                question_str += "<span class='select_li'>"+ que_attrs[i] +"</span>";
            }
            question_str += "</span>";
            $("#que_out_" + question.id).html(question_str);
        }
    } else if ((parseFloat(question.correct_type) == 3) || (parseFloat(question.correct_type) == 5)) {
        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
            question_str += "<textarea cols='' readonly rows='' class='input_tk "+ bk_color +"'"
            + " id='question_answer_"+ question.id +"' onclick=\"javascript:show_select_color("
            + problem.id +", '"+ question.id +"', '"+ question.correct_type +"', '"
            + problem.question_type +"')\" name='question_answer_"
            + question.id +"' style='width:" + erea_with(answer_hash.get(question.id)[0]) +";height:20px;' >"
            + answer_hash.get(question.id)[0] +"</textarea>";
        } else {
            question_str += "<textarea cols='' readonly rows='' onclick=\"javascript:show_select_color("
            + problem.id +", '"+ question.id +"', '"+ question.correct_type
            +"', '" + problem.question_type +"')\" class='input_tk "+ bk_color +"' id='question_answer_"+ question.id
            +"' name='question_answer_" + question.id +"'></textarea>";
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
        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
            question_str += "<span id='question_answer_"+question.id+"' onclick=\"javascript:show_select_color("
            + problem.id +", '"+ question.id +"', '"+ question.correct_type +"', '"
            + problem.question_type +"')\" class='dragDrop_box "+bk_color+"'>"
            + answer_hash.get(question.id)[0]+"</span>";
        } else {
            question_str += "<span id='question_answer_"+question.id+"' onclick=\"javascript:show_select_color("
            + problem.id +", '"+ question.id +"', '"+ question.correct_type +"', '"
            + problem.question_type +"')\" class='dragDrop_box "+bk_color+"'></span>";
        }
        $("#que_out_" + question.id).html(question_str);
    }
}

//创建错误提示框
function create_review(problem_id, problem_type, question_id) {
    var review_div = create_element("div", null, null, "review_btn", null, "innerHTML");
    var collction_str = "";
    if (user_collection != null && user_collection.indexOf(question_id) > -1) {
        collction_str = "<span id='c_c_"+ question_id +"'><a href='javascript:void(0);'>已收藏</a></span>";
    } else {
        collction_str = "<span id='c_c_"+ question_id +"'><a href='javascript:void(0);' onclick=\"javascript:create_collection("
        + problem_id +",'" + question_id +"', '"+ problem_type +"');\" class='scang_btn'>收藏</a></span>";
    }
    review_div.innerHTML = " <a href='javascript:void(0);' onclick='javascript:show_analysis("
    +  question_id + ");' class='jiexi_btn'>解析</a>" + collction_str
    + "<a href='javascript:void(0);' onclick='javascript:show_error_div("
    +  question_id + ");' class='upErrorTo_btn'>报告错误</a>";
    return review_div;
}

//创建收藏
function create_collection(problem_id, question_id, problem_type) {
    var user_answer = ($("#u_answer_"+question_id).attr("value") != undefined)
    ? $("#u_answer_"+question_id).val() : null;    
    if (problem_type == "1") {
        $.ajax({
            type: "POST",
            url: "/collections/add_collection.json",
            dataType: "json",
            data : {
                "problem_id":problem_id,
                "question_id":question_id,
                "problem_json":$("#p_json_"+problem_id).val(),
                "question_answer":$("#q_answer_"+question_id).val(),
                "question_analysis":$("#q_analysis_"+question_id).html(),
                "user_answer":user_answer,
                "paper_id":$("#paper_id").val(),
                "exam_user_id":$("#exam_user_id").val(),
                "category_id":$("#category_id").val()
            },
            success : function(data) {
                tishi_alert(data["message"]);
                $("#c_c_"+question_id).html("<a href='javascript:void(0);'>已收藏</a>");
                user_collection.push(question_id);
            }
        });
    } else {
        $.ajax({
            type: "POST",
            url: "/collections/update_collection.json",
            dataType: "json",
            data : {
                "problem_id":problem_id,
                "question_id":question_id,
                "problem_json":$("#p_json_"+problem_id).val(),
                "question_answer":$("#q_answer_"+question_id).val(),
                "question_analysis":$("#q_analysis_"+question_id).html(),
                "user_answer":user_answer,
                "paper_id":$("#paper_id").val(),
                "exam_user_id":$("#exam_user_id").val(),
                "category_id":$("#category_id").val()
            },
            success : function(data) {
                tishi_alert(data["message"]);
                $("#c_c_"+question_id).html("<a href='javascript:void(0);'>已收藏</a>");
                user_collection.push(question_id);
            }
        });
    }    
}

//显示ul，以及显示解析
function show_select(problem_id, question_id, correct_type, problem_type) {
    $(".borde_blue").removeClass("borde_blue");
    $("#question_attr_" + question_id).addClass("borde_blue");
    $("#select_ul_" + question_id).css("display", "");
    show_question_review(problem_id, question_id, correct_type, problem_type);
}

//清除前面的选中，并选中当前框
function show_select_color(problem_id, question_id, correct_type, problem_type) {
    $(".borde_blue").removeClass("borde_blue");
    $("#question_answer_" + question_id).addClass("borde_blue");
    show_question_review(problem_id, question_id, correct_type, problem_type);
}

//显示可拖动题的解析按钮
function show_question_review(problem_id, question_id, correct_type, problem_type) {
    $("#problem_title_" + problem_id + " .review_btn").remove();
    $("#problem_title_" + problem_id + " .jiexi").remove();
    $("#problem_title_"+problem_id).append(create_review(problem_id, problem_type, question_id));
    $("#problem_title_"+problem_id).append(create_analysis(question_id, correct_type));
}

//创建解析框
function create_analysis(question_id, correct_type) {
    var analysis_div = create_element("div", null, "analysis_" + question_id, "jiexi", null, "innerHTML");
    analysis_div.style.display = "none";
    var answer = "";
    if (true_answers.get(question_id) != null && true_answers.get(question_id)[0] != null) {
        if (correct_type == "2") {
            answer = (true_answers.get(question_id)[0] == "1") ? "对/是" : "错/否";
        } else {
            answer = (true_answers.get(question_id)[0]).replace(/;|;/g, "<br/>");
        }
    }
    var analysis = (true_answers.get(question_id) != null && true_answers.get(question_id)[1] != null)
    ? "解析：" + true_answers.get(question_id)[1] : "";
    var answer_text = correct_type == "5" ? "参考" : "正确";
    analysis_div.innerHTML = "<span class='xx_x' onclick=\"javascript:$('#analysis_"
    + question_id +"').css('display', 'none');\"><img src='/assets/x.png'></span>";
    if (answer != "") {
        analysis_div.innerHTML += "<div>"+ answer_text +"答案：<span class='red'>"+ answer +"</span></div>";
    }
    if (analysis != "") {
        analysis_div.innerHTML += "<div>"+ analysis +"</div>";
    }
    if (answer_hash != null && answer_hash.get(question_id) != null && answer_hash.get(question_id)[2] != null) {
        analysis_div.innerHTML += "<div>得分理由："+ answer_hash.get(question_id)[2] +"</div>";
    }
    return analysis_div;
}

//显示错误弹出框
function show_error_div(question_id) {
    generate_flash_div(".upErrorTo_tab");
    $("#report_error_question_id").attr("value", question_id);
    $("#report_error_description").attr("value", "");
    $('.upErrorTo_tab').css('display', 'block');
}

//添加question所需div
function create_question(problem, question_id_input, parent_div, question, innerHTML, drag_li_arr) {
    question_id_input.value += "" + question.id + ",";
    var hidden_text = "";
    var answer = "";
    if (true_answers.get(question.id) != null && true_answers.get(question.id)[0] != null) {
        answer = true_answers.get(question.id)[0];
    }
    hidden_text += "<input type='hidden' id='q_answer_"+ question.id +"' value='"+ answer +"' />";
    var analysis = (true_answers.get(question.id) != null && true_answers.get(question.id)[1] != null)
    ? true_answers.get(question.id)[1] : "";
    hidden_text += "<div style='display:none;' id='q_analysis_"+ question.id +"'>"+ analysis +"</div>";
    var user_answer = (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "")
    ? answer_hash.get(question.id)[0] : "";
    hidden_text += "<input type='hidden' id='u_answer_"+ question.id +"' value='"+ user_answer +"' />";
    var que_out_div = create_element("div", null, "que_out_" + question.id, "question_area", null, "innerHTML");
    que_out_div.innerHTML = hidden_text + "<div class='area_left'>" + innerHTML + ".</div>";
    parent_div.appendChild(que_out_div);
    var single_question_div = create_element("div", null, "single_question_" + question.id, "area_right", null, "innerHTML");
    if (question.description != undefined && question.description != null && question.description != "") {
        single_question_div.innerHTML += "<div class='question_title'>" +
        question.description + "</div>";
    }
    que_out_div.appendChild(single_question_div);
    que_out_div.appendChild(create_element("div", null, null, "clear", null, "innerHTML"));
    create_single_question(single_question_div, question, drag_li_arr);
    single_question_div.appendChild(create_review(problem.id, problem.question_type, question.id));
    que_out_div.appendChild(create_analysis(question.id, question.correct_type));
}

//显示解析
function show_analysis(question_id) {
    $("#analysis_" + question_id).css("display", "block");
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
            }
        }
    }
}

//创建不同题型
function create_single_question(que_div, question, drag_li_arr) {
    var bk_color = "correctWrong_bg";
    if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] != null
        && answer_hash.get(question.id)[0] != ""
        && $.trim(answer_hash.get(question.id)[0]) == $.trim(true_answers.get(question.id)[0])) {
        // parseFloat(answer_hash.get(question.id)[1]) == parseFloat(question.score) 此处用分数比较已不适用
        bk_color = "correctRight_bg";
    }
    if (question.questionattrs != undefined && question.questionattrs != null) {
        var que_attrs = question.questionattrs.split(";-;");
        
        if (question.correct_type == "6") {
            var drag_div = create_element("div", null, null, "answer_text " + bk_color, null, "innerHTML");
            if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                drag_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='width:"+ erea_with(answer_hash.get(question.id)[0])
                +";height:"+erea_height("20px;", answer_hash.get(question.id)[0]) +";' readonly>"
                + answer_hash.get(question.id)[0] +"</textarea>";
            } else {
                drag_div.innerHTML += "<textarea id='question_answer_"+ question.id +"' name='question_answer_"
                + question.id +"' style='height: 20px;' readonly></textarea>";
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
                } else {
                    var attr = create_element("li", null, null, null, null, "innerHTML");
                    ul.appendChild(attr);
                    if (question.correct_type == "0") {
                        if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != ""
                            && $.trim(answer_hash.get(question.id)[0]) == $.trim(que_attrs[i])) {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\" checked='true'/>";
                            attr.className = bk_color;
                        } else {
                            attr.innerHTML += "<input type='radio' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\"/>";
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
                            + que_attrs[i] +"\" checked='true'/>";
                            attr.className = bk_color;
                        }
                        else {
                            attr.innerHTML += "<input type='checkbox' name='question_attr_"+ question.id +"' id='question_attr_"+ i +"' value=\""
                            + que_attrs[i] +"\"/>";
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
                attr1.innerHTML = "<li class='"+ bk_color +"'><input type='radio' id='question_attr_1' name='question_attr_"
                + question.id +"' value='1' checked='true'/>对/是&nbsp;&nbsp;</li>";
            } else {
                attr1.innerHTML = "<li><input type='radio' id='question_attr_1' name='question_attr_"+ question.id
                +"' value='1'/>对/是&nbsp;&nbsp;</li>";
            }

            if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id)[0] == "0") {
                attr1.innerHTML += "<li class='"+ bk_color +"'><input type='radio' id='question_attr_0' name='question_attr_"
                + question.id +"' value='0' checked='true' />错/否&nbsp;&nbsp;</li>";
            } else {
                attr1.innerHTML += "<li><input type='radio' id='question_attr_0' name='question_attr_"+ question.id
                +"' value='0'/>错/否&nbsp;&nbsp;</li>";
            }
        } else {
            var answer_text = "";
            if (question.correct_type == "3") {
                if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                    answer_text = "<textarea cols='' rows='' class='answer_input "+ bk_color +"'"
                    + " id='question_answer_"+ question.id +"' name='question_answer_"
                    + question.id +"' style='width:" + erea_with(answer_hash.get(question.id)[0]) +";height:"
                    + erea_height("20px;", answer_hash.get(question.id)[0]) +";' readonly>"
                    + answer_hash.get(question.id)[0] +"</textarea>";
                } else {
                    answer_text = "<textarea cols='' rows='' class='answer_input' id='question_answer_"+ question.id
                    +"' name='question_answer_" + question.id +"' style='height: 20px;' readonly></textarea>";
                }
            } else {
                if (answer_hash != null && answer_hash.get(question.id) != null && answer_hash.get(question.id) != "") {
                    answer_text = "<textarea cols='' rows='' class='answer_textarea "+ bk_color
                    +"' id='question_answer_"+ question.id +"' name='question_answer_"+ question.id +"' readonly>"
                    + answer_hash.get(question.id)[0] +"</textarea>";
                } else {
                    answer_text = "<textarea cols=''  rows='' class='answer_textarea' id='question_answer_"+ question.id
                    +"' name='question_answer_"+ question.id +"' readonly></textarea>";
                }
            }
            que_div.innerHTML += answer_text;
        }

    }
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

//loadxml文件
function loadxml(xmlFile) {
    var xmlDoc;
    try {
        if(window.ActiveXObject) {
            xmlDoc = new ActiveXObject('MSXML2.DOMDocument');
            xmlDoc.async = false;
            xmlDoc.load(xmlFile);
        }else if (document.implementation&&document.implementation.createDocument) {
            var xmlhttp = new window.XMLHttpRequest();
            xmlhttp.open("GET", xmlFile, false);
            xmlhttp.send(null);
            xmlDoc = xmlhttp.responseXML;
        }else{
            return null;
        }
        return xmlDoc;
    } catch (e) {
        var flash_div = create_element("div", null, "flash_notice", "tab", null, "innerHTML");
        flash_div.innerHTML = "<p>您的浏览器安全级别设置过高，屏蔽了一些功能，请您重新设置您的浏览器安全级别。</p>";
        document.body.appendChild(flash_div);
        show_flash_div();
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
                answer_hash.put(questions[i].getAttribute("id"), 
                    [answer, questions[i].getAttribute("score"), questions[i].getAttribute("score_reason")]);
            }
        }
    //            var collections = xmlDom.getElementsByTagName("collections");
    //            if (collections.length > 0 && collections[0].firstChild != undefined) {
    //                user_collection = collections[0].firstChild.data.split(",");
    //            }
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
        var audio_str = generate_jplayer_div(block_id);
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
    })(jQuery)
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

//ajax报告错误
function ajax_report_error(){
    $.ajax({
        type: "POST",
        url: "/exam_users/ajax_report_error.json",
        dataType: "json",
        data : {
            "post":{
                "paper_id":$("#report_error_paper_id").val(),
                "paper_title":$("#paper_title").html(),
                "user_id":$("#report_error_user_id").val(),
                "user_name":$("#report_error_user_name").val(),
                "description":$("#report_error_description").val(),
                "error_type":$(".report_error_radio:checked").val(),
                "question_id":$("#report_error_question_id").val(),
                "category_id":$("#category_id").val()
            }
        },
        success : function(data) {
            tishi_alert(data["message"]);
            $('.upErrorTo_tab').css('display', 'none');
        }
    });
}
