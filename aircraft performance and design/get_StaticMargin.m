% C2.5
function [Hn] = get_StaticMargin(h)

get_VT

Hn = (h0-h)+(VT*(a1/a)*(1-drf));
end