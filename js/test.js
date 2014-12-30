var eventSource = new EventSource('/stream');

eventSource.addEventListener('open', function(e) {
  console.log("opened eS");
}, false);

eventSource.onmessage = function(e) {
  console.log(e.data);
}

eventSource.addEventListener('error', function(e) {
  console.log("error: " + e.eventPhase);
  if (e.eventPhase == EventSource.CLOSED) {
    console.log("stream closed");
  }
}, false);

$( "#test_form" ).submit(function( event ) {

  // Stop form from submitting normally
  event.preventDefault();
  var $form = $( this ),
    url = $form.attr( "action" );
  console.log("url: " + url);
  // Send the data using post
  $.post( url );
});
