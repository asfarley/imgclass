function increase_brightness(hex, percent){

		// if(percent == 100 || percent == 100.0)
		// {
		// 	return hex;
		// }

    // strip the leading # if it's there
    hex = hex.replace(/^\s*#|\s*$/g, '');

    // convert 3 char codes --> 6, e.g. `E0F` --> `EE00FF`
    if(hex.length == 3){
        hex = hex.replace(/(.)/g, '$1$1');
    }

    var r = parseInt(hex.substr(0, 2), 16),
        g = parseInt(hex.substr(2, 2), 16),
        b = parseInt(hex.substr(4, 2), 16);

    return '#' +
       ((0|(1<<8) + r + (256 - r) * percent / 100).toString(16)).substr(1) +
       ((0|(1<<8) + g + (256 - g) * percent / 100).toString(16)).substr(1) +
       ((0|(1<<8) + b + (256 - b) * percent / 100).toString(16)).substr(1);
}

//function renderCoverage(coverage,elementID, outlineColor = "#0000AA",fillColor = "#DDDDFF", elementWidth = 1, elementHeight = 20)
function renderCoverage(coverage, elementID, outlineColor, fillColor, elementWidth, elementHeight)
{
	elementWidth = 300.0 / coverage.length;

	coverage_max = coverage.reduce(function(a, b) {
    return Math.max(a, b);
	});

  coverage_min = coverage.reduce(function(a, b) {
    return Math.min(a, b);
  });

	//console.log("Coverage_max: " + coverage_max);

	var canvas = document.getElementById(elementID);
	if (canvas.getContext) {
		var ctx = canvas.getContext('2d');
		ctx.strokeStyle=outlineColor;
		ctx.rect(0,0,coverage.length*elementWidth,elementHeight);
		ctx.stroke();
		ctx.fillStyle=fillColor;
		for(var i=0; i<coverage.length;i++)
		{
			var integer_index = Math.round(i*elementWidth);
			var integer_width = Math.round(elementWidth);
			if(integer_width < 0)
			{
				integer_width = 0;
			}

			if((coverage[i] - coverage_min) != 0)
			{
				percent = 100*(coverage[i]/coverage_max);
				adjusted_fill = increase_brightness("#010101", percent);
				if(coverage[i] == coverage_max)
				{
					adjusted_fill = "#FFFFFF";
				}
				ctx.fillStyle=adjusted_fill;
        ctx.strokeStyle=adjusted_fill;
				ctx.fillRect(integer_index,0,elementWidth,elementHeight);
				//ctx.stroke();
			}
			else {
				ctx.fillStyle="#000000";
        ctx.strokeStyle="#000000";
				ctx.fillRect(integer_index,0,elementWidth,elementHeight);
				//ctx.stroke();
			}
		}

    var fontHeight = elementHeight * 0.8;
    var ctxfontString = fontHeight.toString() + "pt Arial";
    console.log("ctxfontString is " + ctxfontString);
    ctx.font = fontHeight.toString() + "pt arial";
    //ctx.fillStyle="#ff0066";
    //ctx.strokeStyle="#ff0066";
    ctx.fillStyle="#ffffff";
    ctx.lineWidth = 1;
    ctx.strokeStyle="#000000";
    if(coverage_min > 0)
    {
      ctx.fillText("+" + coverage_min.toString(), 10, elementHeight - 0.1 * elementHeight);
      ctx.strokeText("+" + coverage_min.toString(), 10, elementHeight - 0.1 * elementHeight);
    }
	}
}
