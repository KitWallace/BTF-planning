import module namespace pa = "http://kit.wallace.co.uk/lib/pa" at "lib/pa.xqm";
declare namespace h = "http://www.w3.org/1999/xhtml";

declare option exist:serialize "method=xhtml media-type=text/html";

(: map  geocoded planning application comments

:)

declare function local:markers($application) {
<script type="text/javascript">
var markers = [
    
   { string-join(
       for $comment in $application/comments/comment[geocode]
       let $geocode := $comment/geocode
       let $address := replace($geocode/address,"'",'"')
       let $icon := 
                        if ($comment/object)
                        then "http://maps.gstatic.com/mapfiles/ridefinder-images/mm_20_red.png"
                        else if ($comment/support) 
                        then "http://maps.gstatic.com/mapfiles/ridefinder-images/mm_20_green.png"
                        else "http://maps.google.com/mapfiles/kml/pal4/icon57.png"
       let $description := <div><h4>{$address}</h4>
                               {if ($comment/object) then "OBJECT " else if ($comment/support) then "SUPPORT " else ()} 
 
                          </div>
       let $sdescription := util:serialize($description,"method=xhtml media-type=text/html indent=no") 
       return
          concat("['",$address,"',",
                  $comment/geocode/latitude/string(),",",$comment/geocode/longitude/string(),
                  ",'",$sdescription,"','",$icon,"']")
       ,",&#10;")
     }
     ];

var centre =  new google.maps.LatLng({concat($application/summary/latitude,",",$application/summary/longitude)});
var init_zoom = 14;
</script> 
};
let $keyval:= request:get-parameter("keyval",())
let $application := pa:get-application($keyval)
let $title := concat("Map of ",$application/summary/reference)
return
<html>
   <head>
      <meta charset="UTF-8"/>
      <title>{$title}</title>
      <script src="https://maps.googleapis.com/maps/api/js?key={$pa:googlekey}"></script> 
      {local:markers($application)}
      <script type="text/javascript" src="javascript/comment-map.js"></script> 
   </head>
   <body onload="initialize()"> 
      <h1><a href="https://bristoltrees.space/Planning">Home</a> Planning Application <a href="https://bristoltrees.space/Planning/application/{$keyval}">{$application/summary/reference/string()}</a> </h1>      
      <h2>Map of addresses of public comments</h2>
      <div>Of the {count($application//comment)} submissions, {count($application//comment[geocode])} were geocoded. Click on marker for address. </div>
      <div id="map_canvas" style="position: absolute; top: 150px;  left:20px; width: 90%; height:800px;"></div>
   </body>
</html>
