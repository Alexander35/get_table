-module(worker).

-compile(export_all).

read(File_Name)->
        {ok, File} = file:read_file(File_Name),
        Splited_File = binary:split(File,[<<"\n">>],[global]),
        [ binary:split(S, [<<";">>],[global]) || S <- Splited_File ]. %%fullsplitted file

mask_sort([])->
	List =  [[X, <<" ;\n">>] || {X, astlu} <- ets:tab2list(contracts)],
	file:write_file("exclude_contracts.csv", List),
	List1 = [[X, <<" - ">>, X1, <<" ;\n">>] || {X, X1} <- ets:tab2list(contracts), X1/=astlu],
	file:write_file("may_be_include_contracts.csv", List1);
	

mask_sort([H|R]) ->
	case H of
		%%Billing_text
		[Cont, Addr,_,_] ->
			ets:insert(contracts, [{Cont, Addr}]);
		%%Astlu_text 
		[_,Contr,_,_,_,_] ->
			case ets:lookup(contracts, Contr) of
				[] ->
					ets:insert(contracts, [{Contr, astlu}]);
				[{Contr,_}] ->
					true = ets:delete(contracts, Contr);
				_Els-> 
					io:format("err",[])
			end;
		Other ->
			io:format("~p is unmatched~n", [Other] )
	end,
	mask_sort(R).

mask_s(B, A) -> 
	mask_sort(B),
	mask_sort(A).
	
