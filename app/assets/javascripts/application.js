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

//提示框弹出层
function show_flash_div() {
    $('#flash_notice').stop(null,true);
    generate_flash_div("#flash_notice");
    setTimeout(function(){
        jQuery('#flash_notice').fadeTo("slow",0);
    }, 2500);
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
    var div = create_element("div",null,"flash_notice","tab",null,null);
    var p = create_element("p","","","","innerHTML");
    p.innerHTML = str;
    div.appendChild(p);
    var body = jQuery("body");
    body.append(div);
    show_flash_div();
}