function renderCoverage(coverage,elementID, outlineColor = "#0000AA",fillColor = "#DDDDFF", elementWidth = 1, elementHeight = 20)
{
	elementWidth = 300.0 / coverage.length;

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

			if((coverage[i] == 1) | (coverage[i] == true))
			{
				ctx.fillStyle=fillColor;
				ctx.fillRect(integer_index,0,elementWidth,elementHeight);
				ctx.stroke();
			}
			else {
				ctx.fillStyle="#000000";
				ctx.fillRect(integer_index,0,elementWidth,elementHeight);
				ctx.stroke();
			}
		}
	}
}
