var map;
var position;
var infowindow = null;
var marker;

function htmlDecode(input){
  var e = document.createElement('div');
  e.innerHTML = input;
  return e.childNodes[0].nodeValue;
}

function initialize() {
  div = document.getElementById("map_canvas");
  map = new google.maps.Map(div,{
      zoom:  init_zoom,
      center: centre,
      mapTypeId: 'roadmap'
      }); 
   addMarkers();
   infowindow =  new google.maps.InfoWindow( {
          content: "loading ... "
       });         
   if (markers.length == 1) {
        google.maps.event.addListenerOnce(map, 'zoom_changed', function() {
             map.setZoom(17); 
        });
       }
   else if (markers.length == 0) {
      map.position(centre);
      map.setZoom(init_zoom);
      }
 }   

function addMarkers() {
   for (i in markers){
       var m = markers[i];
       var text = htmlDecode(m[3]);        
       position = new google.maps.LatLng(m[1],m[2]);
       var icon = m[4];
          marker = new google.maps.Marker({
          position: position,
          title: m[0],
          map: map,
          icon: icon,
          html: text
       });
       google.maps.event.addListener(marker,'click', function() {
            infowindow.setContent(this.html);
            infowindow.open(map, this);
        });
   }
 }
 
