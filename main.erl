-module(main).

-export([main/1, main/0]).

main()->
	main({bad,args}).

main([Arg])->
        case Arg of
                "stop" ->
                        server:stop();
                "start" ->
                        server:start_link(),
                        server:mask(),
			server:stop();
		_Other ->
			{err, bad_args}
        end;

main([]) -> 
	{err, bad_args}.
