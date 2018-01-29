function djb2(t){for(var e=5381,n=0;n<t.length;n++)e=(e<<5)+e+t.charCodeAt(n);return e}function hashStringToColor(t){var e=djb2(t),n=(16711680&e)>>16,i=(65280&e)>>8,r=255&e;return"#"+("0"+n.toString(16)).substr(-2)+("0"+i.toString(16)).substr(-2)+("0"+r.toString(16)).substr(-2)}function uuidv4(){return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,function(t){var e=16*Math.random()|0;return("x"==t?e:3&e|8).toString(16)})}function replacer(t,e){return"uuid"==t?undefined:"selected"==t?undefined:e}function BoundingBox(t,e,n,i,r,u){this.x=t,this.y=e,this.width=n,this.height=i,this.classname=r,this.uuid=uuidv4(),this.selected=!1,this.id=u}function RedrawBoundingBoxes(t,e){for(var n=document.getElementById(e);n.hasChildNodes();)n.removeChild(n.lastChild);t.forEach(function(t){DrawEachBoundingBox(t,e)})}function DrawBoundingBox(t,e,n,i,r,u,o){var l="http://www.w3.org/2000/svg",d=document.createElementNS(l,"rect"),h=$("#"+o),x=$("#"+o).prev(),s=t*x.width(),a=e*x.height(),c=n*x.width(),g=i*x.height(),S="0 0 "+x.width().toString()+" "+x.height().toString();h.attr("viewbox",S),d.setAttributeNS(null,"x",s),d.setAttributeNS(null,"y",a),d.setAttributeNS(null,"height",g.toString()),d.setAttributeNS(null,"width",c.toString());var f=hashStringToColor(u);d.setAttributeNS(null,"stroke",f),d.setAttributeNS(null,"fill",f),r?d.setAttributeNS(null,"fill-opacity","0.5"):d.setAttributeNS(null,"fill-opacity","0.0"),d.setAttributeNS(null,"stroke-width","3"),document.getElementById(o).appendChild(d);var b=document.createElementNS(l,"text");b.setAttributeNS(null,"x",s),b.setAttributeNS(null,"y",a),b.innerHTML=u,document.getElementById(o).appendChild(b)}function DrawEachBoundingBox(t,e){DrawBoundingBox(t.x,t.y,t.width,t.height,t.selected,t.classname,e)}