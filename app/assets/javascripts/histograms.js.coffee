# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
data = d3.map(JSON.parse($("#chart-data").val()))
spliced_data = []

$ ->
  draw_chart(data)

draw_chart = (data) ->
  width = 900
  height = 500

  y = d3.scale.linear()
    .domain([0, d3.max(data.values())])
    .range([0, height])
  
  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  chart = d3.select(".chart")
    .attr("width", width)
    .attr("height", height)

  barWidth = width / data_array.length

  bar = chart.selectAll("g")
      .data(data_array)
  
  bar.attr("transform", (d, i) -> 
        return "translate(" + i * barWidth + ",0)"
      )
      .selectAll("rect")
      .attr("height", (d) ->
        return y(d.value)
      )
      .attr("y", (d) ->
        return height - y(d.value)
      )
      .attr("width", barWidth - 1)
      .attr("fill", (d) ->
        return d.key
      )
      .on("click", (d) ->
        return removeBar(d)
      )
   
  bar.enter().append("g")
      .attr("transform", (d, i) -> 
        return "translate(" + i * barWidth + ",0)"
      )
      .append("rect")
      .attr("height", (d) ->
        return y(d.value)
      )
      .attr("y", (d) ->
        return height - y(d.value)
      )
      .attr("width", barWidth - 1)
      .attr("fill", (d) ->
        return d.key
      )
      .on("click", (d) ->
        removeBar(d)
      )
  
  bar.exit().remove()

removeBar = (d) ->
  spliced_data.push(d)
  res = data.remove(d.key)
  draw_chart(data)

