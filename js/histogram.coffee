data = d3.map(JSON.parse($("#chart-data").val()))
spliced_data = []

width = $(".chart-container").width()
height = 500

y = d3.scale.linear()
  .range([0, height])

r = Math.min(width, height)/2

arc = d3.svg.arc()
  .outerRadius(r)

$ ->
  draw_chart(data)

draw_pie = (data) ->
  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  d3.select("svg").selectAll("*").remove()

  vis = d3.select(".chart")
    .append("svg:svg")
    .data([data_array])
    .attr("width", width)
    .attr("height", height)
    .append("svg:g")
    .attr("transform", "translate(" + r + "," + r + ")")

  pie = d3.layout.pie()
    .value((d) ->
      return d.value
    )

  arcs = vis.selectAll("g.slice")
    .data(pie)
    .enter()
    .append("svg:g")
    .attr("class", "slice")

  arcs.append("svg:path")
    .attr("fill", (d, i) ->
      return d.data.key
    )
    .attr("d", arc)
    .on("click", (d) ->
      removeArc(d.data)
    )

draw_chart = (data) ->
  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  y.domain(d3.extent(data.values()))

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
  
  y.domain(d3.extent(data.values()))

  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  bar = chart.selectAll("g")
    .data(data_array, (d) ->
      return d.key
    )
  
  barWidth = width / data_array.length

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

redraw_pie = () ->
  data_array = data.entries()
  data_array.sort((a, b) ->
    return a.value - b.value
  )

  vis = d3.select(".chart")
        .select("svg")
        .select("g")

  pie = d3.layout.pie()
    .value((d) ->
      return d.value
    )

  path = vis.selectAll("g.slice")
    .data(pie(data_array), (d) ->
      d.data.key
    )

  path.enter()
    .append("path")
    .attr("d", arc)
    .attr("fill", (d, i) ->
      return d.data.key
    )
    .on("click", (d) ->
      removeArc(d.data)
    )

  path.transition()
    .duration(1000)
    .select("path")
    .attr("d", arc)
  
  path.exit()
    .remove()

removeBar = (d) ->
  spliced_data.push(d)
  data.remove(d.key)
  redraw_chart()

removeArc = (d) ->
  spliced_data.push(d)
  data.remove(d.key)
  redraw_pie()

$('#reset').click( (event) ->
  data.set(d.key, d.value) for d in spliced_data
  spliced_data = []
  redraw_chart()
  event.preventDefault()
)

$('#pie').click( (event) ->
  draw_pie(data)
  event.preventDefault()
)
