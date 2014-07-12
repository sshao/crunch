# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
$ ->
  data = d3.map(JSON.parse($("#chart-data").val()))
  x = d3.scale.linear().domain([0, d3.max(data.values())]).range([0,420])
  data = data.entries()
  d3.select(".chart")
    .selectAll("div")
      .data(data)
    .enter().append("div")
      .style("height", (d) -> 
        return x(d.value) + "px" 
      )
      .style("background-color", (d) ->
        return d.key
      )
      .text((d) ->
        return d.key
      )

