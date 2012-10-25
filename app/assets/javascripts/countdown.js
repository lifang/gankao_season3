/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var myTime = new Object;
myTime.seconds = 0;
myTime._isEnd = false;

myTime.start = function(sec)
{
    if(myTime.timeId != null){
        clearInterval(myTime.timeId);
    }
    myTime.seconds = sec;
    $(".pt_time").html(myTime.showFormat());
    myTime.timeId = setInterval("myTime.takeCount()", 1000);
}

myTime.takeCount = function(){
    if(myTime.seconds == 0){
        myTime._isEnd = true;
        clearInterval(myTime.timeId);
        try{
            callback();
        }catch(e){}
        return;
    }
    myTime.seconds -= 1;
    $(".pt_time").html(myTime.showFormat());
}

myTime.showFormat = function(){
    
    hours = parseInt(myTime.seconds/60/60);
    hours >= 10 ? housrs = hours : hours ="0"+hours ;
    minutes = parseInt(myTime.seconds/60);
    minutes >= 10 ? minutes = minutes : minutes ="0"+ minutes ;
    seconds = myTime.seconds%60;
    seconds >= 10 ? seconds = seconds : seconds ="0"+ seconds ;
    return hours+":"+minutes+":"+seconds;
}

//定时器的初始参数
var local_start_time = null;
var local_timer = null;
var local_save_time = null;
function local_save_start() {
    local_save_time = new Date();
    local_timer = window.setInterval(function(){
        local_save();
    }, 100);
}
//定时执行函数
function local_save() {
    var start_date = new Date();
    if (local_start_time <= 0) {
        if (parseInt(local_start_time) == parseFloat(local_start_time)) {
            $(".pt_time").html("00:00:00");
            window.clearInterval(local_timer);
            try{
                callback();
            }catch(e){}
            return;
        }
    }
    if (parseInt(local_start_time) == parseFloat(local_start_time)) {
        var h = Math.floor(local_start_time/3600) < 10 ?
            ("0" + Math.floor(local_start_time/3600)) : Math.floor(local_start_time/3600);
        var m = Math.floor((local_start_time%3600)/60) < 10 ?
            ("0" + Math.floor((local_start_time%3600)/60)) : Math.floor((local_start_time%3600)/60);
        var s = (local_start_time - h*3600 - m*60) < 10 ?
            ("0" + Math.floor(local_start_time - h*3600 - m*60)) : Math.floor(local_start_time - h*3600 - m*60);
        $(".pt_time").html(h + ":" + m + ":" + s);
    }
    var end_date = new Date();
    if ((end_date - local_save_time) > 500 && (end_date - local_save_time) < 5000) {
        local_start_time = Math.round((local_start_time - (end_date - local_save_time)/1000)*10)/10;
    } else {
        local_start_time = Math.round((local_start_time - 0.1 - (end_date - start_date)/1000)*10)/10;
    }
    local_save_time = end_date;
}
