// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require main

function generate_flash_div(style) {
    var scolltop = document.body.scrollTop|document.documentElement.scrollTop;
    var win_height = document.documentElement.clientHeight;//jQuery(document).height();
    var win_width = jQuery(window).width();
    var z_layer_height = jQuery(style).height();
    var z_layer_width = jQuery(style).width();
    jQuery(style).css('top',(win_height-z_layer_height)/2 + scolltop);
    jQuery(style).css('left',(win_width-z_layer_width)/2);
    jQuery(style).css('display','block');
}




function generate_tip_div(style) {
    jQuery(style).css('top',($(".plan_tab").height() - $(style).height())/2);
    jQuery(style).css('left',($(".plan_tab").width() - $(style).width())/2);
    jQuery(style).css('display','block');
}

//提示框弹出层
function show_flash_div() {
    $('#flash_notice').stop(null,true);
    generate_flash_div("#flash_notice");
    setTimeout(function(){
        jQuery('#flash_notice').fadeTo("slow",0);
    }, 3000);
    setTimeout(function(){
        $('#flash_notice').remove();
    }, 3000);
}

//创建元素
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
    }
    else {
        ele.value = "";
    }
    return ele;
}

//弹出错误提示框
function tishi_alert(str){
    $('#flash_notice').remove();
    var div = create_element("div",null,"flash_notice","tab",null,null);
    var p = create_element("p","","","","innerHTML");
    p.innerHTML = str;
    div.appendChild(p);
    var body = jQuery("body");
    body.append(div);
    show_flash_div();
}

//加入收藏夹
function addfavorite() {
    var ua = navigator.userAgent.toLowerCase();
    var isWebkit = (ua.indexOf('webkit') != - 1);
    var isMac = (ua.indexOf('mac') != - 1);
    if (document.all){
        window.external.addFavorite('http://www.gankao.co','赶考网');
        tishi_alert("您已经成功将赶考网添加到收藏夹。");
    } else if (window.sidebar) {
        window.sidebar.addPanel('赶考网', 'http://www.gankao.co', "");
        tishi_alert("您已经成功将赶考网添加到收藏夹。");
    } else if (isWebkit || isMac) {
        var str = (isMac ? 'Command/Cmd' : 'CTRL') + ' + D';
        tishi_alert((str) ? '请按' + str + '来收藏此页。' : str);
    }    
}

//关闭收藏夹
function close_shortcut() {
    var sc_time = getCookie("sc_time");
    if (sc_time == null) {
        setCookie("sc_time", "1", 2592000000, '/');
    } else {
        setCookie("sc_time", ""+(new Number(sc_time) + 1).toString(), 2592000000, '/');
    }
    setCookie("shortcut", "1", 172800000, '/');
    $(".shortcut").remove();
}
