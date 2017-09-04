// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var BoundingBoxes = [];

function GetSelectedClass()
{
  return "Car";
}

function BoundingBox(x,y,width,height,classname)
{
  this.x = x;
  this.y = y;
  this.width = width;
  this.height = height;
  this.classname = classname;
}

function FindPosition(oElement)
{
  var rect = oElement.getBoundingClientRect();
  return [ rect.left, rect.top ];
}

function GetCoordinatesDown(e)
{
  var PosX = 0;
  var PosY = 0;
  var ImgPos;
  ImgPos = FindPosition(mainimage);
  if (!e) var e = window.event;
  if (e.pageX || e.pageY)
  {
    PosX = e.pageX;
    PosY = e.pageY;
  }
  else if (e.clientX || e.clientY)
    {
      PosX = e.clientX + document.body.scrollLeft
        + document.documentElement.scrollLeft;
      PosY = e.clientY + document.body.scrollTop
        + document.documentElement.scrollTop;
    }

  PosXDown =  Math.round(PosX - ImgPos[0]);
  PosYDown =  Math.round(PosY - ImgPos[1]);
}

function DrawBoundingBox(x,y,width,height)
{
  var svgns = "http://www.w3.org/2000/svg";
  var rect = document.createElementNS(svgns, 'rect');
  rect.setAttributeNS(null, 'x', x - width);
  rect.setAttributeNS(null, 'y', y - height);
  rect.setAttributeNS(null, 'height', height.toString());
  rect.setAttributeNS(null, 'width', width.toString());
  rect.setAttributeNS(null, 'stroke', '#FFFFFF');
  rect.setAttributeNS(null, 'stroke-width', '3');
  rect.setAttributeNS(null, 'fill-opacity', '0.0');
  document.getElementById('overlay').appendChild(rect);
}

function DrawEachBoundingBox(boundingBox,index)
{
  DrawBoundingBox(boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height);
}

function GetCoordinatesUp(e)
{
  var PosX = 0;
  var PosY = 0;
  var ImgPos;
  ImgPos = FindPosition(mainimage);
  if (!e) var e = window.event;
  if (e.pageX || e.pageY)
  {
    PosX = e.pageX;
    PosY = e.pageY;
  }
  else if (e.clientX || e.clientY)
    {
      PosX = e.clientX + document.body.scrollLeft
        + document.documentElement.scrollLeft;
      PosY = e.clientY + document.body.scrollTop
        + document.documentElement.scrollTop;
    }

  PosXUp = Math.round(PosX - ImgPos[0]);
  PosYUp = Math.round(PosY - ImgPos[1]);

  var height = PosYUp - PosYDown;
  var width = PosXUp - PosXDown;

  //Delete old rectangles
  var overlay = document.getElementById('overlay')
  while (overlay.hasChildNodes()) {
    overlay.removeChild(overlay.lastChild);
  }

  var classname = GetSelectedClass();
  var bb = new BoundingBox(PosXUp,PosYUp,width,height,classname);
  BoundingBoxes.push(bb);
  BoundingBoxes.forEach(DrawEachBoundingBox);
}

$(function() {
  var mainimage = document.getElementById("mainimage");
   mainimage.onmousedown = GetCoordinatesDown;
   mainimage.onmouseup = GetCoordinatesUp;

   var overlay = document.getElementById("overlay");
   overlay.onmousedown = GetCoordinatesDown;
   overlay.onmouseup = GetCoordinatesUp;

   var PosXDown, PosYDown;
   var PosXUp, PosYUp;

   //Select first item as default selected radiocontainer
});
