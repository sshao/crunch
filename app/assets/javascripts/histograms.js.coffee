data = d3.map(JSON.parse($("#chart-data").val()))
spliced_data = []

width = 900
height = 500

$ ->
  draw_chart(data)

draw_chart = (data) ->
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

redraw_chart = () ->
  chart = d3.select(".chart")

  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  bar = chart.selectAll("g")
    .data(data_array, (d) ->
      return d.key
    )
  
  barWidth = width / data_array.length
  
  y = d3.scale.linear()
    .domain([0, d3.max(data.values())])
    .range([0, height])

  bar.transition()
    .duration(1000)
    .attr("transform", (d, i) ->
        return "translate(" + i * barWidth + ",0)"
      )
    .select("rect")
      .attr("height", (d) ->
        return y(d.value)
      )
      .attr("y", (d) ->
        return height - y(d.value)
      )
      .attr("width", barWidth - 1)

  bar.exit()
    .remove()

removeBar = (d) ->
  spliced_data.push(d)
  data.remove(d.key)
  redraw_chart()

