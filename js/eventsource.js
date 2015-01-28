var source = new EventSource("/stream");

source.addEventListener('message', function(e) {
  if (e.origin != window.location.origin) {
    console.log("Error: Message origin was not " + window.location.origin)
    return;
  }
  else {
    var progress = e.data

    if (progress.trim()) {
      $(".meter").css('width', (progress * 10) + '%');
    }
  }
}, false);

source.addEventListener('open', function(e) {
  console.log("EventSource connection opened");
}, false);

source.addEventListener('error', function(e) {
  if (e.readyState == EventSource.CLOSED) {
    console.log("Error: EventSource connection lost");
  }
  else {
    console.log("Error: EventSource connection error");
  }
}, false);
