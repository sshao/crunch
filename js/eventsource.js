var source = new EventSource("/stream");

source.addEventListener('message', function(e) {
  var progress = e.data
  if (progress.trim()) {
    console.log(progress);
    $(".status").text(progress);
  }
}, false);

source.addEventListener('open', function(e) {
  console.log("es open");
  $(".status").text("es open");
}, false);

source.addEventListener('error', function(e) {
  if (e.readyState == EventSource.CLOSED) {
    console.log("es closed");
  }
}, false);
