// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function FindPosition(oElement)
{
  var rect = oElement.getBoundingClientRect();
  return [ rect.left, rect.top ];
}

function GetCoordinates(e)
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

  PosX = PosX - ImgPos[0];
  PosY = PosY - ImgPos[1];
  document.getElementById("x").innerHTML = Math.round(PosX);
  document.getElementById("y").innerHTML = Math.round(PosY);
}

$(function() {
  var mainimage = document.getElementById("mainimage");
  mainimage.onmousedown = GetCoordinates;
});
