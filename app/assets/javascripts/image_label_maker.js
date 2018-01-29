// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var BoundingBoxes = [];
var Dragging = false;

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
  RedrawBoundingBoxes(BoundingBoxes, 'overlay');
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

  RedrawBoundingBoxes(BoundingBoxes, 'overlay');
}

function UpdateBoundingBoxList()
{
  var bblist = document.getElementById('bblist');
  if(bblist != null)
  {
    while (bblist.hasChildNodes()) {
      bblist.removeChild(bblist.lastChild);
    }
     BoundingBoxes.forEach(insertBoundingBoxListElement);

     var target = document.getElementById('target');
     var serializedBoundingBoxes = SerializeBoundingBoxes();
     target.setAttribute("value", serializedBoundingBoxes);
  }
}

function FindPosition(oElement)
{
  var rect = oElement.getBoundingClientRect();
  return [ rect.left, rect.top ];
}

function GetCoordinatesDown(e)
{
  Dragging = true;
  var PosX = 0;
  var PosY = 0;
  var ImgPos;
  ImgPos = FindPosition(mainimage);
  console.log(ImgPos);
  if (!e) var e = window.event;
  //if (e.pageX || e.pageY)
  if(false)
  {
    console.log("e.pageX || e.pageY");
    console.log("e.pageX: " + e.pageX.toString())
    console.log("e.pageY: " + e.pageY.toString())
    PosX = e.pageX;
    PosY = e.pageY;
  }
  else if (e.clientX || e.clientY)
    {
      console.log("e.clientX || e.clientY");
      console.log("e.clientX: " + e.clientX.toString())
      console.log("e.clientY: " + e.clientY.toString())
      PosX = e.clientX;// + document.body.scrollLeft
        //+ document.documentElement.scrollLeft;
      PosY = e.clientY; + document.body.scrollTop
        //+ document.documentElement.scrollTop;
    }

  PosXDown =  Math.round(PosX - ImgPos[0]);
  PosYDown =  Math.round(PosY - ImgPos[1]);

  console.log("PosXDown: " + PosXDown.toString())
  console.log("PosYDown: " + PosYDown.toString())
}

function RenderWhileDragging(e)
{
  if(Dragging)
  {
    console.log("Dragging..")
  }
  else {
    return;
  }
  var PosX = 0;
  var PosY = 0;
  var ImgPos;
  ImgPos = FindPosition(mainimage);
  console.log(ImgPos);
  if (!e) var e = window.event;
  if (e.clientX || e.clientY)
  {
    PosX = e.clientX;// + document.body.scrollLeft
      //+ document.documentElement.scrollLeft;
    PosY = e.clientY;// + document.body.scrollTop
      //+ document.documentElement.scrollTop;
  }

  PosXNow = Math.round(PosX - ImgPos[0]);
  PosYNow = Math.round(PosY - ImgPos[1]);

  var height = Math.abs(PosYNow - PosYDown);
  var width = Math.abs(PosXNow - PosXDown);
  var x = Math.min(PosXNow, PosXDown);
  var y = Math.min(PosYNow, PosYDown);

  var classname = GetSelectedClass();

  //Map x,y,height,width to coordinates in normalized coordinates (0.0->1.0 for each dimension)
  var mainimagejq = $("#mainimage");
  var x_scaled = x / mainimagejq.width();
  var y_scaled = y / mainimagejq.height();
  var width_scaled = width / mainimagejq.width();
  var height_scaled = height / mainimagejq.height();

  var bb = new BoundingBox(x_scaled,y_scaled,width_scaled,height_scaled,classname);
  var DragBoundingBoxes = BoundingBoxes.slice();
  DragBoundingBoxes.push(bb);
  RedrawBoundingBoxes(DragBoundingBoxes, 'overlay');
}

function GetCoordinatesUp(e)
{
  Dragging = false;
  var PosX = 0;
  var PosY = 0;
  var ImgPos;
  ImgPos = FindPosition(mainimage);
  console.log(ImgPos);
  if (!e) var e = window.event;
  //if (e.pageX || e.pageY)
  if(false)
  {
    console.log("e.pageX || e.pageY");
    console.log("e.pageX: " + e.pageX.toString())
    console.log("e.pageY: " + e.pageY.toString())
    PosX = e.pageX;
    PosY = e.pageY;
  }
  else if (e.clientX || e.clientY)
  {
    console.log("e.clientX || e.clientY");
    console.log("e.clientX: " + e.clientX.toString())
    console.log("e.clientY: " + e.clientY.toString())
    PosX = e.clientX;// + document.body.scrollLeft
      //+ document.documentElement.scrollLeft;
    PosY = e.clientY;// + document.body.scrollTop
      //+ document.documentElement.scrollTop;
  }

  PosXUp = Math.round(PosX - ImgPos[0]);
  PosYUp = Math.round(PosY - ImgPos[1]);

  console.log("PosXUp: " + PosXUp.toString())
  console.log("PosYUp: " + PosYUp.toString())

  var height = Math.abs(PosYUp - PosYDown);
  var width = Math.abs(PosXUp - PosXDown);
  var x = Math.min(PosXUp, PosXDown);
  var y = Math.min(PosYUp, PosYDown);

  var classname = GetSelectedClass();

  //Map x,y,height,width to coordinates in normalized coordinates (0.0->1.0 for each dimension)
  var mainimagejq = $("#mainimage");
  var x_scaled = x / mainimagejq.width();
  var y_scaled = y / mainimagejq.height();
  var width_scaled = width / mainimagejq.width();
  var height_scaled = height / mainimagejq.height();

  var bb = new BoundingBox(x_scaled,y_scaled,width_scaled,height_scaled,classname);
  BoundingBoxes.push(bb);
  UpdateBoundingBoxList();
  RedrawBoundingBoxes(BoundingBoxes, 'overlay');
}

function RedrawAllBoundingBoxes()
{
  if (typeof BoundingBoxesGroups !== 'undefined')
  {
      BoundingBoxesGroups.forEach(function(item,index) {
      RedrawBoundingBoxes(item.BoundingBoxes, item.overlayElementId);
    });
  }
}

//$(function() {
$(document).on("ready, turbolinks:load", function() {
  var mainimage = document.getElementById("mainimage");
  if(mainimage != null)
  {
    mainimage.onmousedown = GetCoordinatesDown;
    mainimage.onmouseup = GetCoordinatesUp;
    mainimage.onmousemove = RenderWhileDragging;
  }

   var overlay = document.getElementById("overlay");
   if(overlay != null)
   {
     overlay.onmousedown = GetCoordinatesDown;
     overlay.onmouseup = GetCoordinatesUp;
     overlay.onmousemove = RenderWhileDragging;
   }

   //Select first item as default selected radiocontainer
   var firstRadioSelection = $(":radio")[0];
   if(firstRadioSelection != null)
   {
     firstRadioSelection.checked = true;
   }

   var PosXDown, PosYDown;
   var PosXUp, PosYUp;

   if(overlay != null)
   {
     UpdateBoundingBoxList();
     RedrawBoundingBoxes(BoundingBoxes, 'overlay');
   }
});
