; A builder script that...well, builds! similar to `tsc .`
(require 'cljs.build.api)

(cljs.build.api/build "src" {:output-to "out/main.js"})