clear all

r = 5 ;

dt = 0.01 ;
t = 0:dt:2*pi ;
N = length(t) ;
f_t = zeros(1,N) ; g_t = zeros(1,N) ; h_t = zeros(1,N) ;

for i = 1:N
    f_t(i) = r * cos(t(i)) ; 
    g_t(i) = r * sin(t(i)) ;
end

plot(f_t,g_t)
