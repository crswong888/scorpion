clear all
format longeng

syms xi eta
X = sym('x', [8 1]) ;
Y = sym('y', [8 1]) ;

N(1) = -(1 - xi) * (1 - eta) * (1 + xi + eta) / 4 ;
N(2) = -(1 + xi) * (1 - eta) * (1 - xi + eta) / 4 ;
N(3) = -(1 + xi) * (1 + eta) * (1 - xi - eta) / 4 ;
N(4) = -(1 - xi) * (1 + eta) * (1 + xi - eta) / 4 ;
N(5) = (1 - xi * xi) * (1 - eta) / 2 ;
N(6) = (1 + xi) * (1 - eta * eta) / 2 ;
N(7) = (1 - xi * xi) * (1 + eta) / 2 ;
N(8) = (1 - xi) * (1 - eta * eta) / 2 ;

x = N * X ;
y = N * Y ;

J = [ diff(x, xi) diff(y, xi) ; diff(x, eta) diff(y, eta) ] ;

%%% hint: use <string> = latex(<equation>) & clipboard('copy',<string>) to output a latex format