# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
$ ->
  data = d3.map(JSON.parse($("#chart-data").val()))
  width = 900
  height = 500

  console.log(d3.max(data.values()))

  y = d3.scale.linear()
    .domain([0, d3.max(data.values())])
    .range([0, height])
  
  data = data.entries()
  data.sort((a, b) ->
    return a.value - b.value
  )

  chart = d3.select(".chart")
    .attr("width", width)
    .attr("height", height)

  barWidth = width / data.length

  bar = chart.selectAll("g")
      .data(data)
    .enter().append("g")
      .attr("transform", (d, i) -> 
        return "translate(" + i * barWidth + ",0)"
      )

  bar.append("rect")
    .attr("height", (d) ->
      console.log("mapped " + d.value + " to " + y(d.value))
      return y(d.value)
    )
    .attr("y", (d) ->
      return height - y(d.value)
    )
    .attr("width", barWidth - 1)
    .attr("fill", (d) ->
      return d.key
    )

