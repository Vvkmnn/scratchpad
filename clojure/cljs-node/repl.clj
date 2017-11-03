; A repl for Node
; rlwrap java -cp cljs.jar:src clojure.main node_repl.clj
; lein run -m clojure.main repl.clj
(require 'cljs.repl)
(require 'cljs.build.api)
(require 'cljs.repl.node)

(cljs.build.api/build "src"
                      {:main 'cljs-node.core
                       :output-to "out/main.js"
                       :verbose true})

(cljs.repl/repl (cljs.repl.node/repl-env)
                :watch "src"
                :output-dir "out")