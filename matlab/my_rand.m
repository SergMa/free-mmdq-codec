% Generate uniformly distributed random number in [minx...maxx] range
function x = my_rand( minx, maxx )

    x = (maxx-minx) * rand(1) + minx;

return
