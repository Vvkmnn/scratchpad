; The lumo builder.
; Similar to the standard builder, except for the advanced optimizations
(require '[lumo.build.api :as b])

(b/build "src"
  {:main 'cljs-lumo.core
   :output-to "main.js"
   :optimizations :advanced
   :target :nodejs})
