Array.prototype.indexOf=function(el, index){
    var n = this.length>>>0, i = ~~index;
    if(i < 0) i += n;
    for(; i < n; i++) if(i in this && this[i] === el) return i;
    return -1;
};

if(typeof(HTMLElement) != "undefined"){
    HTMLElement.prototype.contains = function(obj){
        while(obj != null && typeof(obj.tagName) != "undefined"){
            if(obj == this)
                return true;
            obj = obj.parentNode;
        }
        return false;
    };
}

function close_tab(tab) {
    tab.parentNode.parentNode.style.display = "none";
}

function flash_remove(tab) {
    tab.parentNode.parentNode.removeChild(tab.parentNode);
}


////提示框弹出层
//function show_flash_div() {
//    $('#tishi_notice').stop();
//    generate_flash_div("#tishi_notice");
//    $('#tishi_notice').delay(3500).fadeTo("slow",0,function(){
//        $(this).remove();
//    });
//}

function checkspace(checkstr){
    var str = '';
    for(var i = 0; i < checkstr.length; i++) {
        str = str + ' ';
    }
    if (str == checkstr){
        return true;
    } else{
        return false;
    }
}

//弹出不自动关闭的提示框
function show_flash_not_close() {
    generate_flash_div(".tishi_tab0");
}

////弹出错误提示框
//function tishi_alert(str){
//    var div = create_element("div",null,"tishi_notice","tishi_tab",null,null);
//    var p = create_element("p","","","","innerHTML");
//    p.innerHTML = str;
//    div.appendChild(p);
//    var body = jQuery("body");
//    body.append(div);
//    show_flash_div();
//}


