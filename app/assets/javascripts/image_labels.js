// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

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
  document.getElementById("x").innerHTML = PosXDown;
  document.getElementById("y").innerHTML = PosYDown;
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
  document.getElementById("x").innerHTML = PosXUp;
  document.getElementById("y").innerHTML = PosYUp;

  var height = PosYUp - PosYDown;
  var width = PosXUp - PosXDown;

  var svgns = "http://www.w3.org/2000/svg";
  var rect = document.createElementNS(svgns, 'rect');
  rect.setAttributeNS(null, 'x', PosXDown);
  rect.setAttributeNS(null, 'y', PosYDown);
  rect.setAttributeNS(null, 'height', height.toString());
  rect.setAttributeNS(null, 'width', width.toString());
  rect.setAttributeNS(null, 'stroke', '#FFFFFF');
  rect.setAttributeNS(null, 'stroke-width', '3');
  rect.setAttributeNS(null, 'fill-opacity', '0.0');
  document.getElementById('overlay').appendChild(rect);
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
});
