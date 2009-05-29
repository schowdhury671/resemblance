-module(main).
-compile(export_all).
-include("consts.hrl").
-include("debug.hrl").

main() ->
    start(),
    {ok,B} = file:read_file("test"),
    Lines = string:tokens(binary_to_list(B),"\n"),
%    process(["the cat sat","on the mat","in the tree","cat tree mat"],0).
    process(Lines,1).


process([],_) ->
    dump();

process([Str|T],Id) ->
    d("processing ~p ~p\n",[Id,Str]),
    Shingles = util:shingles(Str),
%    d("id ~p shingles ~p\n",[Id,Shingles]),
    get(sketch_rr_router) ! { Id, {shingles,Shingles} },
%    timer:sleep(1),
    process(T,Id+1).

dump() ->
    timer:sleep(500),
    get(sic) ! dump,
    dump().
 
start() ->
    put(ts, util:tostr()),
    put(sic, sketches_in_common:start()),
    put(sti, sketch_to_id:start(get(sic))),
    put(sketchers, [ sketcher:start(get(sti)) || _ <- lists:seq(1, ?SKETCH_SIZE)]),
    put(sketch_rr_router, rr_router:start(get(sketchers))).

%stop() ->
%    get(sketch_rr_router) ! stop.
	       