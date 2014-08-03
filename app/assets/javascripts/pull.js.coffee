$ ->
  $("#update").click( (event) ->
    id = $("#histogram-id").attr("histogram-id")
    counter = 10
    $.ajax({
      url: "#{id}/#{counter}/pull",
      type: 'POST',
    })
    event.preventDefault()
  )
