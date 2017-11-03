; The lumo builder.
(require 'lumo.build.api)

(lumo.build.api/build "src"
                      {:main 'cljs-lumo.core
                       :output-to "out/main.js"
                       :optimizations :advanced
                       :target :nodejs})
