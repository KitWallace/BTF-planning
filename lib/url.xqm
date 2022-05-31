module namespace url = "http://kitwallace.me/url";

declare function url:parse-path($steps) {
     if (count($steps) = 0)
     then ()
     else if (count($steps) = 1)
     then element {$steps[1]} {()}
     else  (element {$steps[1]} {$steps[2]}, url:parse-path(subsequence($steps,3)))   
};


declare function url:path-to-sig($steps) {
   string-join(
      for $step at $i in $steps 
      return 
          if ($i mod 2 = 0) then "*" else $step
       ,"/")
};

declare function url:get-context() as element(context) {  
   let $path := request:get-parameter("_path",())
   let $path := if (ends-with($path,"/")) then substring($path, 1, string-length($path) - 1) else $path 
   let $format := tokenize($path,"\.")[last()]
   let $format := if ($format = ("xml","csv","rss","html")) then $format else ()
   let $path := if ($format)
                then substring-before($path,concat(".",$format))
                else $path
   let $steps := tokenize($path,"/")
   let $signature := string-join(url:path-to-sig($steps),"/")
   return
     element context {
       for $param in request:get-parameter-names()
         let $value := request:get-parameter($param,())
         return element {$param} {attribute qs {"true"} ,string-join($value,",")},
       if ($format) then element _format {$format} else (),
       element _nparam {count(request:get-parameter-names())},
       element _signature {$signature},
       for $step in $steps return element _step {$step},
       url:parse-path($steps)
     }
};

