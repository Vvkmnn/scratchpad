; A Helper Script to build Node
(require 'cljs.build.api)

; Targets Node
; npm install source-map-support for great source mapping...support...
(cljs.build.api/build "src"
                      {:main 'hello-world.core
                       :output-to "out/main.js"
                       :target :nodejs})