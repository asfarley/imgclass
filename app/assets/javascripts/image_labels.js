// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var BoundingBoxes = [];

function djb2(str){
  var hash = 5381;
  for (var i = 0; i < str.length; i++) {
    hash = ((hash << 5) + hash) + str.charCodeAt(i); /* hash * 33 + c */
  }
  return hash;
}

function hashStringToColor(str) {
  var hash = djb2(str);
  var r = (hash & 0xFF0000) >> 16;
  var g = (hash & 0x00FF00) >> 8;
  var b = hash & 0x0000FF;
  return "#" + ("0" + r.toString(16)).substr(-2) + ("0" + g.toString(16)).substr(-2) + ("0" + b.toString(16)).substr(-2);
}

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

function replacer(key,value)
{
    if (key=="uuid") return undefined;
    else if (key=="selected") return undefined;
    else return value;
}

function SerializeBoundingBoxes()
{
    return JSON.stringify(BoundingBoxes,replacer);
}

function GetSelectedClass()
{
  var selectedRadio = $("input:radio:checked")[0];
  return selectedRadio.value;
}

function DeleteSelectedBoxes()
{
  var selectedBoxes = $("li.active");
  selectedBoxes.each(DeleteBoundingBox);
  RedrawBoundingBoxes();
}

function DeleteBoundingBox(index, boundingBoxLi)
{
  var uuid = boundingBoxLi.getAttribute("uuid");
  BoundingBoxes = BoundingBoxes.filter(function(boundingBox){
    return (boundingBox.uuid != uuid);
  });

  boundingBoxLi.outerHTML = "";
  delete boundingBoxLi;
}

function insertBoundingBoxListElement(boundingBox, index)
{
  var li = document.createElement("li");
  li.innerHTML = boundingBox.classname;
  li.classList.add('list-group-item');
  li.setAttribute("uuid", boundingBox.uuid);
  li.onclick = ToggleBoundingBoxListElement;
  document.getElementById('bblist').appendChild(li);
}

function ToggleBoundingBoxListElement()
{
  $(this).toggleClass('active');

  var uuid = $(this).attr("uuid");
  var thisbox = BoundingBoxes.filter(function(boundingBox){
    return (boundingBox.uuid == uuid);
  })[0];

  if($(this).hasClass('active'))
  {
    thisbox.selected = true;
  }
  else {
    thisbox.selected = false;
  }

  RedrawBoundingBoxes();
}

function UpdateBoundingBoxList()
{
  var bblist = document.getElementById('bblist');
  while (bblist.hasChildNodes()) {
    bblist.removeChild(bblist.lastChild);
  }
   BoundingBoxes.forEach(insertBoundingBoxListElement);

   var target = document.getElementById('target');
   var serializedBoundingBoxes = SerializeBoundingBoxes();
   target.setAttribute("value", serializedBoundingBoxes);
}

function BoundingBox(x,y,width,height,classname)
{
  this.x = x;
  this.y = y;
  this.width = width;
  this.height = height;
  this.classname = classname;
  this.uuid = uuidv4();
  this.selected = false;
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

function RedrawBoundingBoxes()
{
  //Delete old rectangles
  var overlay = document.getElementById('overlay')
  while (overlay.hasChildNodes()) {
    overlay.removeChild(overlay.lastChild);
  }
  BoundingBoxes.forEach(DrawEachBoundingBox);
}

function DrawBoundingBox(x,y,width,height,selected, classname)
{
  var svgns = "http://www.w3.org/2000/svg";
  var rect = document.createElementNS(svgns, 'rect');
  rect.setAttributeNS(null, 'x', x);
  rect.setAttributeNS(null, 'y', y);
  rect.setAttributeNS(null, 'height', height.toString());
  rect.setAttributeNS(null, 'width', width.toString());

  var color = hashStringToColor(classname);
  rect.setAttributeNS(null, 'stroke', color);
  rect.setAttributeNS(null, 'fill', color);

  if(selected)
  {
    rect.setAttributeNS(null, 'fill-opacity', '0.5');
  }
  else {
    rect.setAttributeNS(null, 'fill-opacity', '0.0');
  }

  rect.setAttributeNS(null, 'stroke-width', '3');
  document.getElementById('overlay').appendChild(rect);

  var text = document.createElementNS(svgns, 'text');
  text.setAttributeNS(null, 'x', x);
  text.setAttributeNS(null, 'y', y);
  text.innerHTML = classname;
  document.getElementById('overlay').appendChild(text);
}

function DrawEachBoundingBox(boundingBox,index)
{
  DrawBoundingBox(boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height, boundingBox.selected, boundingBox.classname);
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

  var height = Math.abs(PosYUp - PosYDown);
  var width = Math.abs(PosXUp - PosXDown);
  var x = Math.min(PosXUp, PosXDown);
  var y = Math.min(PosYUp, PosYDown);

  var classname = GetSelectedClass();
  var bb = new BoundingBox(x,y,width,height,classname);
  BoundingBoxes.push(bb);
  UpdateBoundingBoxList();
  RedrawBoundingBoxes();
}

$(function() {
  var mainimage = document.getElementById("mainimage");
   mainimage.onmousedown = GetCoordinatesDown;
   mainimage.onmouseup = GetCoordinatesUp;

   var overlay = document.getElementById("overlay");
   overlay.onmousedown = GetCoordinatesDown;
   overlay.onmouseup = GetCoordinatesUp;

   //Select first item as default selected radiocontainer
   var firstRadioSelection = $(":radio")[0];
   firstRadioSelection.checked = true;

   var PosXDown, PosYDown;
   var PosXUp, PosYUp;

   UpdateBoundingBoxList();
   RedrawBoundingBoxes();
});
