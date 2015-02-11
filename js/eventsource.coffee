source = new EventSource("/stream");

source.addEventListener("message", (e) ->
  if e.origin != window.location.origin
    console.log("Error: Message origin was not " + window.location.origin)
    return
  else
    json = JSON.parse(e.data)
    progress = json.status

    $(".meter").css("width", progress + "%")

    if progress == 100
      username = json.username
      window.location.replace("/show?username=" + username);
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

$("form").submit((e) ->
  e.preventDefault()

  $.ajax({
    type: 'post',
    url: '/create',
    data: $("form").serialize()
  })
)
