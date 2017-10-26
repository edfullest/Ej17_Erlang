% Juan Ordaz A01191576
% Eduardo Serna A01196007
% ejercicio 17 (Ejercicio 2 de Erlang)

-module(ej17).

-export([prueba_calcula/0, inicio/0]).

-import(timer, [sleep/1]).

% 2 calcula
%
% c(ej17).
% ej17:prueba_calcula().

prueba_calcula() ->
    Calculadora = inicio(),
    Impresora = spawn(fun () -> imprime() end),
    Calculadora ! {ultimo, Impresora},
    sleep(10), % Se introduce el sleep despues de ultimo para sincronizar el output, 
               % y que no aparezca primero el output de suma que el de la operacion ultimo
    Calculadora ! {suma, 3, 5},
    Calculadora ! {ultimo, Impresora},
    sleep(10), 
    Calculadora ! {multiplica, 2, 2},
    Calculadora ! {total, Impresora},
    Calculadora ! {ultimo, Impresora}.  

inicio() ->
    GT_PID = spawn(fun () -> guarda_total(0) end),
    GU_PID = spawn(fun () -> guarda_ultimo() end),
    spawn(fun () -> calcula(GT_PID, GU_PID) end).

imprime()->
receive
    {total, Number} -> io:format(">>>Total<<< = ~p ~n" ,[Number]), 
                       imprime();
    {ultimo, Number} -> io:format(">>>Ultimo valor calculado<<< = ~p ~n" ,[Number]), 
                        imprime()
end.

calcula(GT_PID, GU_PID) ->
receive
    {suma, X, Y} ->
        Resultado = X + Y,
        io:format("~p + ~p = ~p~n" ,[X,Y,Resultado]),
        GT_PID ! {sumar, Resultado},
        GU_PID ! {guardar, Resultado},
        calcula(GT_PID, GU_PID);
    {multiplica, X, Y} ->
        Resultado = X * Y,
        io:format("~p * ~p = ~p~n" ,[X,Y,Resultado]),
        GT_PID ! {sumar, Resultado},
        GU_PID ! {guardar, Resultado},
        calcula(GT_PID, GU_PID);
    {ultimo, P} ->
        GU_PID ! {ultimo, P},
        calcula(GT_PID, GU_PID);
    {total, P} ->
        GT_PID ! {total, P},
        calcula(GT_PID, GU_PID)
end.

guarda_total(Total) ->
receive 
    {sumar, Nuevo} -> guarda_total(Total + Nuevo);
    {total, IMPRESORA_PID} -> IMPRESORA_PID ! {total, Total}, 
                              guarda_total(Total)
end.


guarda_ultimo(Ultimo) ->
receive
    {guardar, Nuevo} -> guarda_ultimo(Nuevo);
    {ultimo, IMPRESORA_PID} -> IMPRESORA_PID ! {ultimo, Ultimo}, 
                               guarda_ultimo(Ultimo)
end.

guarda_ultimo() ->
receive
    {guardar, Nuevo} -> guarda_ultimo(Nuevo);
    {ultimo, _} -> io:format("ERROR! No se ha realizado ninguna operación ~n"), 
                   guarda_ultimo()
end.
