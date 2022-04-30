% Useage order = getOrder(n_sticks, intersections)
% 
% n_sticks - the number of sticks in image.
% intersections - a 2d matrix where each row represents an intersection
%                 with position, the indexes of the lines that intersect
%                 there, and the index of the line that is on top
%                 (i.e. [x, y, lines1_index, line2_index, top_index])
%
% order - a vector containing the stick indexes in an appropriate pick up
%         order.  (such that stick index in position 1 would be the first 
%         stick picked up)
function order = getOrder(n_sticks, intersections)

matrix = zeros(n_sticks+1,'logical');

for i=1:size(intersections,1)
    if intersections(i,5) == intersections(i,3)
        matrix(intersections(i,3), intersections(i,4)) = 1;
    elseif intersections(i,5) == intersections(i,4)
        matrix(intersections(i,4), intersections(i,3)) = 1;
    end
end

matrix(n_sticks+1, :) = ones(size(matrix(n_sticks+1,:)));
matrix(n_sticks+1, n_sticks+1) = 0;

%get topological order
graph = digraph(matrix);
order = toposort(graph);
order = order(2:(n_sticks+1));

%find isolated sticks and move them to front of the order if they aren't
%there already.
col_sums = sum(matrix,1);
row_sums = sum(matrix,2);
vals = col_sums'+row_sums;
isolated = find(vals==1);

for i=1:size(isolated)
    index = find(order == isolated(i));
    if index > 1
        order(2:index) = order(1:index-1);
        order(1) = isolated(i);
    end
end
