function increase_brightness(e,t){e=e.replace(/^\s*#|\s*$/g,""),3==e.length&&(e=e.replace(/(.)/g,"$1$1"));var r=parseInt(e.substr(0,2),16),n=parseInt(e.substr(2,2),16),l=parseInt(e.substr(4,2),16);return"#"+(0|256+r+(256-r)*t/100).toString(16).substr(1)+(0|256+n+(256-n)*t/100).toString(16).substr(1)+(0|256+l+(256-l)*t/100).toString(16).substr(1)}function renderCoverage(e,t,r,n,l,i){l=300/e.length,coverage_max=e.reduce(function(e,t){return Math.max(e,t)}),coverage_min=e.reduce(function(e,t){return Math.min(e,t)});var a=document.getElementById(t);if(a.getContext){var o=a.getContext("2d");o.strokeStyle=r,o.rect(0,0,e.length*l,i),o.stroke(),o.fillStyle=n;for(var s=0;s<e.length;s++){var g=Math.round(s*l),c=Math.round(l);c<0&&(c=0),e[s]-coverage_min!=0?(percent=e[s]/coverage_max*100,adjusted_fill=increase_brightness("#010101",percent),e[s]==coverage_max&&(adjusted_fill="#FFFFFF"),o.fillStyle=adjusted_fill,o.strokeStyle=adjusted_fill,o.fillRect(g,0,l,i)):(o.fillStyle="#000000",o.strokeStyle="#000000",o.fillRect(g,0,l,i))}var f=.8*i,u=f.toString()+"pt Arial";console.log("ctxfontString is "+u),o.font=f.toString()+"pt arial",o.fillStyle="#ffffff",o.lineWidth=1,o.strokeStyle="#000000",coverage_min>0&&(o.fillText("+"+coverage_min.toString(),10,i-.1*i),o.strokeText("+"+coverage_min.toString(),10,i-.1*i))}}