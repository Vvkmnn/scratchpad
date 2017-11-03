// Compiled by ClojureScript 1.9.946 {:target :nodejs}
goog.provide('cljs_node.core');
goog.require('cljs.core');
goog.require('cljs.nodejs');
cljs.nodejs.enable_util_print_BANG_.call(null);
cljs_node.core._main = (function cljs_node$core$_main(var_args){
var args__4414__auto__ = [];
var len__4411__auto___37 = arguments.length;
var i__4412__auto___38 = (0);
while(true){
if((i__4412__auto___38 < len__4411__auto___37)){
args__4414__auto__.push((arguments[i__4412__auto___38]));

var G__39 = (i__4412__auto___38 + (1));
i__4412__auto___38 = G__39;
continue;
} else {
}
break;
}

var argseq__4415__auto__ = ((((0) < args__4414__auto__.length))?(new cljs.core.IndexedSeq(args__4414__auto__.slice((0)),(0),null)):null);
return cljs_node.core._main.cljs$core$IFn$_invoke$arity$variadic(argseq__4415__auto__);
});

cljs_node.core._main.cljs$core$IFn$_invoke$arity$variadic = (function (args){
return cljs.core.println.call(null,"Hello world!");
});

cljs_node.core._main.cljs$lang$maxFixedArity = (0);

cljs_node.core._main.cljs$lang$applyTo = (function (seq36){
return cljs_node.core._main.cljs$core$IFn$_invoke$arity$variadic(cljs.core.seq.call(null,seq36));
});

cljs.core._STAR_main_cli_fn_STAR_ = cljs_node.core._main;

//# sourceMappingURL=core.js.map
