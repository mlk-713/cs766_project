% Usage: intersection_points = getIntersections(lines)
% 
% lines - a 2d matrix where each row contains the endpoints
%         of a line representing a stick. (i.e. [pt1_x, pt1_y, pt2_x, pt2_y])
% 
% intersection_points - a 2d matrix where each row represents an intersection
%                       with position and the indexes of the lines that intersect there
%                       (i.e. [x, y, lines1_index, line2_index, 0])
% NOTE: the last column selects which stick is on top at that intersection
% and is NOT set by this function.  Instead requires a call to getTops
% function.
function intersection_points = getIntersections(lines)

%This initial setup is necessary in case there are NO intersections.
intersection_points = zeros(1,5);
intersection_points(1,5) = -1;

ipoint = 1;
for start = 1:size(lines,1)-1
    for second = start+1:size(lines,1)
        L1 = [lines(start,1:2); lines(start,3:4)];
        L2 = [lines(second,1:2); lines(second,3:4)];

        [x, y] = findIntersect(L1,L2);
        min_L1 = [min(L1(1,1), L1(2,1)), min(L1(1,2), L1(2,2))];
        max_L1 = [max(L1(1,1), L1(2,1)), max(L1(1,2), L1(2,2))];
        min_L2 = [min(L2(1,1), L2(2,1)), min(L2(1,2), L2(2,2))];
        max_L2 = [max(L2(1,1), L2(2,1)), max(L2(1,2), L2(2,2))];

        if (min_L1(1,1)<=x && max_L1(1,1)>=x && min_L1(1,2)<=y &&...
                max_L1(1,2)>=y && min_L2(1,1)<=x && max_L2(1,1)>=x &&...
                min_L2(1,2)<=y && max_L2(1,2)>=y)
            intersection_points(ipoint,1:5) = [x,y,start,second,0];
            ipoint = ipoint + 1;
        end
    end
end