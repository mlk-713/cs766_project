% Usage: intersections = getTops(img, lines, intersections)
%
% img - original image for which we are finding a pick up order.
% lines - a 2d matrix where each row contains the endpoints
%         of a line representing a stick.  (i.e. [pt1_x, pt1_y, pt2_x, pt2_y])
% intersections - a 2d matrix where each row represents an intersection
%                 with position and the indexes of the lines that intersect
%                 there. Expected to not include top/bottom info in 5th
%                 column yet.
%                 (i.e. [x, y, lines1_index, line2_index, 0])
%
% intersections - input intersections matrix except updated to contain
%                 top/bottom info in 5th column.
function intersections = getTops(img, lines, intersections)

%For each intersection_points (num,1:4) figure out which two lines are
%involved, so 3:6 and 7:10
for i=1:size(intersections,1)
    intersectx = cast(intersections(i,1),'uint64');
    intersecty = cast(intersections(i,2),'uint64');
    if intersectx > 0
        % get lines for current intersection
        lineOne = intersections(i,3);
        lineTwo = intersections(i,4);
        testxOne = [lines(lineOne,1),lines(lineOne,3)];
        testyOne = [lines(lineOne,2),lines(lineOne,4)];
        testxTwo = [lines(lineTwo,1),lines(lineTwo,3)];
        testyTwo = [lines(lineTwo,2),lines(lineTwo,4)];

        %get line profiles
        [Line_One_Profile_x,Line_One_Profile_y,Line_One_Profile]  = improfile(img,testxOne,testyOne);
        [Line_Two_Profile_x,Line_Two_Profile_y,Line_Two_Profile] = improfile(img,testxTwo,testyTwo);

        %area_of_interest_x = 6 pixel diameter from intersection point,
        area_of_interest_x = [intersectx-2:intersectx+2];
        area_of_interest_y = [intersecty-2:intersecty+2];
        [Prof_Row_x_Int,Prof_Col_x_Int] = find(Line_One_Profile_x>(intersectx-3) & Line_One_Profile_x<(intersectx+3));
        [Prof_Row_y_Int,Prof_Col_y_Int] = find(Line_One_Profile_y>(intersecty-3) & Line_One_Profile_y<(intersecty+3));
        Prof_Result_Int = intersect(Prof_Row_x_Int,Prof_Row_y_Int);

        %get average line colors and average colors in region of interest
        Line_One_RGB = mean(Line_One_Profile,[1 2]);
        Line_Two_RGB = mean(Line_Two_Profile,[1 2]);
        Avg_Int_R = mean(Line_One_Profile([Prof_Result_Int],1,1));
        Avg_Int_G = mean(Line_One_Profile([Prof_Result_Int],1,2));
        Avg_Int_B = mean(Line_One_Profile([Prof_Result_Int],1,3));

        % Use averages to compute difference in color, and select top stick
        Difference_Score_One = sqrt((Avg_Int_R-Line_One_RGB(1,1,1)).^2+(Avg_Int_G-Line_One_RGB(1,1,2)).^2+(Avg_Int_B-Line_One_RGB(1,1,3)).^2);
        Difference_Score_Two = sqrt((Avg_Int_R-Line_Two_RGB(1,1,1)).^2+(Avg_Int_G-Line_Two_RGB(1,1,2)).^2+(Avg_Int_B-Line_Two_RGB(1,1,3)).^2);
        if(Difference_Score_One < Difference_Score_Two)
            intersections(i,5) = lineOne;
        else
            intersections(i,5) = lineTwo;
        end
    end
end