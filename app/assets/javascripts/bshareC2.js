(function(){
    function p(){
        for(g in d.pnMap)j=d.topMap[g]*-26,k+=".bshare-custom .bshare-"+g+'{background:url("'+m+(j?'sprite/top_logos_sprite.gif") no-repeat 0 '+j+"px;":g+'.gif") no-repeat;')+"*display:inline;display:inline-block;}";k+='.bshare-custom #bshare-more-icon,.bshare-custom .bshare-more-icon{background:url("'+m+'more.gif") no-repeat;padding-left:27px;}.bshare-custom .bshare-share-count{width:45px;padding:0 0 0 2px;vertical-align:bottom;background:transparent url('+n+"counter_box_24.gif) no-repeat;height:24px;color:#444;line-height:24px !important;text-align:center;font:bold 12px Arial,\u5b8b\u4f53,sans-serif;*display:inline;display:inline-block;zoom:1;_padding-top:6px;}";
        h.loadStyle(k);
        if(!d.anchorsBinded){
            d.anchorsBinded=!0;
            for(var b=h.getElem(o,"div","bshare-custom"),c=function(e){
                if(!e)e=l.event;
                var a=e.target?e.target:e.srcElement;
                if(a){
                    for(var c=a.className.split(" "),a=a.buttonIndex,b=0;b<c.length;b++)if(!(c[b].length<7)&&c[b].substr(0,7)=="bshare-"){
                        var f=c[b].substr(7);
                        break
                    }
                    if(!f)return!1;
                    if(f==="more")return d.more(e),e.preventDefault?e.preventDefault():e.returnValue=!1,!1;
                    d.share(e,f,a);
                    return!1
                    }
                },i=0;i<b.length;i++)for(var f=b[i].getElementsByTagName("a"),
                a=0;a<f.length;a++)f[a].buttonIndex=i,f[a].href="javascript:void(0);",o.addEventListener?f[a].addEventListener("click",c,!1):f[a].attachEvent("onclick",c)
                }
            }
var l=window,h=l.bShareUtil,d=l.bShare,c=d.config,n=d.imageBasePath,m=n+"logos/m2/",g,j,o=document,k=".bshare-custom{font-size:16px;line-height:24px !important;}.bshare-custom a{text-decoration:none;display:none;zoom:1;height:24px;cursor:pointer;padding-left:27px;vertical-align:middle;color:#2e3192;margin-right:3px;filter:alpha(opacity=100);-moz-opacity:1;-khtml-opacity:1;opacity:1;}.bshare-custom a:hover{text-decoration:underline;filter:alpha(opacity=75);-moz-opacity:0.75;-khtml-opacity:0.75;opacity:0.75;}.bshare-custom .bshare-more{padding-left:0;color:#000;*display:inline;display:inline-block;}.bshare-custom #bshare-shareto{text-decoration:none;font-weight:bold;margin-right:8px;*display:inline;display:inline-block;}";
h.ready(function(){
    var b=function(){
        d.completed?(p(),c.pop>=0&&!c.beta&&!c.popjs&&h.loadScript(d.jsBasePath+"styles/bshareS887.js?v=20120809")):setTimeout(b,50)
        };

    b()
    })
})();
