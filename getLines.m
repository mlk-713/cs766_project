% Usage: final_lines = getLines(n_lines, image)
% 
% n_lines - the number of lines desired.  (i.e. this should end up
%           corresponding to the number of rows in final_lines)
% image - a binary image cleaned of noise. Fed into the built in MATLAB 
%         hough functions.  These functions have built in culling for 
%         nearly identical calculated lines which we abuse to our advantage.
%
% final_lines - n_lines x 4 matrix where each row corresponds to a line
%               representing a stick (i.e. [pt1_x, pt1_y, pt2_x, pt2_y])
function final_lines = getLines(n_lines, image)

%abuse hough function to get lines representing sticks
[H,T,R] = hough(image);
P = houghpeaks(H, n_lines, 'threshold', ceil(0.5*max(H(:))));
lines = houghlines(image, T, R, P, 'FillGap', 5, 'MinLength', 7);
%figure, imshow(clean_img);

%get average length for culling.
len_lines = zeros(size(lines,2),1);
for k = 1:size(lines,2)
    len = norm(lines(k).point1 - lines(k).point2);
    len_lines(k,1) = len;
end
average_len = mean2(len_lines);

%cull lines down to only the lines corresponding to sticks.
final_lines = zeros([size(lines,2)+1,4]); %delibrately allocate extra space
index = 1;
for k = 1:size(lines,2)
    len = norm(lines(k).point1 - lines(k).point2);
    if (len > (average_len/2))
        xy = [lines(k).point1; lines(k).point2];
        final_lines(index,1:4) = [xy(1,1) xy(1,2) xy(2,1) xy(2,2)];
        index = index + 1;
    end
end
%the following line trims final_lines to get rid of extra space.
final_lines = final_lines(1:find(final_lines(:,1)==0,1,'first')-1, :);
