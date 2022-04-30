% Usage: runProject(filename, n_sticks, [option1], [option2])
%
% filename - name of image for which to compute order
% n_sticks - number of sticks in image
%
% optional arguments are "animate" and "debug"
% animate - provides an extremely simple animation for order display.
% debug - displays all features computed during order generation.
function runProject(filename, n_sticks, option1, option2, option3)

% handle option parameters
animate = false;
debug = false;
loadbearing = false;
if exist('option1','var')
    if option1 == "animate"
        animate = true;
    elseif option1 == "debug"
        debug = true;
    elseif option1 == "loadbearing"
        loadbearing = true;
    end
end
if exist('option2','var')
    if option2 == "animate"
        animate = true;
    elseif option2 == "debug"
        debug = true;
    elseif option2 == "loadbearing"
        loadbearing = true;
    end
end
if exist('option3','var')
    if option3 == "animate"
        animate = true;
    elseif option3 == "debug"
        debug = true;
    elseif option3 == "loadbearing"
        loadbearing = true;
    end
end
img = imread(filename);

%get binary image and handle noise
clean_img = cleaning(img);

final_lines = getLines(n_sticks, clean_img);

% getIntersections sets up intersections matrix, but MUST be followed by
% getTops to fill in which stick is on top.  (could be refactored into
% one function, but it felt better to keep the complex getTops code
% isolated.
intersections = getIntersections(final_lines);
intersections = getTops(img, final_lines, intersections);
if(loadbearing)
    load_bearing = getLoadBearing(final_lines, intersections);
end
%debug display: displays final lines, intersections, and helpful labels.
if(debug)
    debugDisplay(img, final_lines, intersections);
end

order = getOrder(n_sticks,intersections);

%display order for pick up
figure; imshow(img);
r = 1;
hold on;
while r <= n_sticks
    if animate
        % a more interesting animation could be inserted here.
        pause(0.75);
    end
    value = num2str(r);
    if(loadbearing)
        if (load_bearing(order(r))==1)
            value = append(value,"LB?");
        end
    end
    text(final_lines(order(r),1)-30, final_lines(order(r),2)-30, value, 'Color', '#FF99FF');
    r = r+1;
end
hold off;
