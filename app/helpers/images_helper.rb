module ImagesHelper

  def renderImageOverlaySVG(image,label)
      html = "<svg id=\"overlay\" xmlns=\"http://www.w3.org/2000/svg\" style=\"left:0px;top:0px;\">"

      targetJSON = JSON.parse(label.target)

      nObjects = targetJSON.count
      targetJSON.each do |bbJSON|
        html += "<rect>"
        html += "</rect>"
      end

      html += "</svg>"
      return html
  end

end
