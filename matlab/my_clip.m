function y = my_clip( x, MAXX )
    y = min(x, MAXX);
    y = max(y,-MAXX);
return