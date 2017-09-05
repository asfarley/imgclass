
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

function RedrawBoundingBoxes(BoundingBoxes,overlayElementId)
{
  //Delete old rectangles
  var overlay = document.getElementById(overlayElementId)
  while (overlay.hasChildNodes()) {
    overlay.removeChild(overlay.lastChild);
  }

  BoundingBoxes.forEach(function (item,index) {
    DrawEachBoundingBox(item,overlayElementId);
  });
}

function DrawBoundingBox(x,y,width,height,selected, classname, overlayElementId)
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
  document.getElementById(overlayElementId).appendChild(rect);

  var text = document.createElementNS(svgns, 'text');
  text.setAttributeNS(null, 'x', x);
  text.setAttributeNS(null, 'y', y);
  text.innerHTML = classname;
  document.getElementById(overlayElementId).appendChild(text);
}

function DrawEachBoundingBox(boundingBox, overlayElementId)
{
  DrawBoundingBox(boundingBox.x, boundingBox.y, boundingBox.width, boundingBox.height, boundingBox.selected, boundingBox.classname, overlayElementId);
}
