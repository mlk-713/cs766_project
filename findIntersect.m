% Usage: [x,y] = findIntersect(L1, L2)
%
% L1 - 2x2 matrix with first line points [pt1x pt1y; pt2x pt2y]
% L2 - 2x2 matrix with second line points [pt1x pt1y; pt2x pt2y]
%
% x - x position of intersection, -1 if no intersection (parallel lines)
% y - y position of intersection, -1 if no intersection (parallel lines)
function [x,y] = findIntersect(L1, L2)

% both vertical lines
if L1(2,1)-L1(1,1) == 0 && L2(2,1)-L2(1,1) == 0
    x = -1;
    y = -1;

% L1 is vertical
elseif L1(2,1)-L1(1,1) == 0
    m2 = (L2(2,2)-L2(1,2))/(L2(2,1)-L2(1,1));
    b2 = L2(1,2) - (m2*L2(1,1));

    x = L1(2,1);
    y = m2*x + b2;

% L2 is vertical
elseif L2(2,1)-L2(1,1) == 0
    m1 = (L1(2,2)-L1(1,2))/(L1(2,1)-L1(1,1));
    b1 = L1(1,2) - (m1*L1(1,1));

    x = L2(2,1);
    y = m1*x + b1;

% general case
else
    m1 = (L1(2,2)-L1(1,2))/(L1(2,1)-L1(1,1));
    b1 = L1(1,2) - (m1*L1(1,1));
    m2 = (L2(2,2)-L2(1,2))/(L2(2,1)-L2(1,1));
    b2 = L2(1,2) - (m2*L2(1,1));
    
    % parallel check
    if m1-m2 == 0
        x = -1;
        y = -1;
    else
        x = (b2-b1)/(m1-m2);
        y = m1*x+b1;
    end
end
