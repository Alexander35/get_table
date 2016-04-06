-module(server).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([ stop/0, mask/0]).

%%divide
mask()->
	gen_server:call(?MODULE, mask_sort).

%%send stop signal
stop() ->
        gen_server:cast(?MODULE, stop).

%%start server
start_link()->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%simple init
init([]) ->
	%%reading keys and save it into tab
	ets:new(files, [set, named_table]),
	Billing = worker:read("billing.csv"),
	Astlu = worker:read("astlu.csv"),
	ets:insert(files, [{billing, Billing}]),
	ets:insert(files, [{astlu, Astlu}]),
	
	%%create table for sorting contracts
	ets:new(contracts, [set, named_table]),
	{ok, start}.

%%Recieving Msg
handle_call(mask_sort,_From,State)->
	[{billing, Billing}] = ets:lookup(files, billing),
	[{astlu, Astlu}] = ets:lookup(files, astlu),
	Reply = worker:mask_s(Billing, Astlu),
		
	{reply, Reply, State}.
	
%%handling stop signal
handle_cast(stop, State) ->
	{stop, normal, State}.

handle_info(_Info, State) ->
	{other, State}.

terminate(Reason, State) ->
	{ok, {Reason, State}}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
