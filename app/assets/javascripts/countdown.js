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
    alert(myTime.seconds);
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