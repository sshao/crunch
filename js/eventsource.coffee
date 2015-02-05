source = new EventSource("/stream");

source.addEventListener("message", (e) ->
  if e.origin != window.location.origin
    console.log("Error: Message origin was not " + window.location.origin)
    return
  else
    progress = e.data

    if progress.trim()
      $(".meter").css("width", progress + "%")
, false)

source.addEventListener("open", (e) ->
  console.log("EventSource connection opened");
, false)

source.addEventListener("error", (e) ->
  if e.readyState == EventSource.CLOSED
    console.log("Error: EventSource connection lost")
  else
    console.log("Error: EventSource connection error")
, false)
