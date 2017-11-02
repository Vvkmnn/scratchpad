; A helper script that watches and build, like `tsc --watch`
(require 'cljs.build.api)

(cljs.build.api/watch "src"
  {:main 'hello-world.core
   :output-to "out/main.js"})