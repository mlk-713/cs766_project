% Usage debugDisplay(img, lines, intersections)
%
% img - image for which to get order information
% lines - line matrix for order computation
% intersections - instersection matrix for order computation
%
% displays an additional figure showing useful debug information on the
% origina image
function debugDisplay(img, lines, intersections)

figure();
imshow(img);
hold on;
for i=1:size(lines,1)
    % Plot lines and labels
    plot([lines(i,1), lines(i,3)], [lines(i,2), lines(i,4)],...
        'LineWidth', 2, 'Color', 'green')
    text(lines(i,3)+10, lines(i,4), num2str(i), 'Color', 'cyan');
    % Plot beginnings and ends of lines
    plot(lines(i,1), lines(i,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
    plot(lines(i,3), lines(i,4), 'x', 'LineWidth', 2, 'Color', 'red');
end

%diplay intersections with labels
for i=1:size(intersections,1)
    if intersections(i,1) > 0
        plot(intersections(i,1), intersections(i,2),...
             'x', 'LineWidth', 2, 'Color', 'blue');
        text(intersections(i,1)+10, intersections(i,2)+10,...
             num2str(i), 'Color', 'blue');
        %plot top stick labels at intersections.
        text(intersections(i,1)+50, intersections(i,2)+10, num2str(intersections(i,5)), 'Color', 'red');
    end
end
hold off;