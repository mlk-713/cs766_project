function loadBearing = getLoadBearing(lines, intersections)
loadBearing = zeros(size(lines,1),1);
load_beared = zeros(size(lines,1),4); % number of line load beared, how many lines above contribute, to left, to right
line_intersection_count = zeros(size(lines,1),1);
for i=1:size(intersections,1)
    if((intersections(i,3)>0) && (intersections(i,4)>0))
        line_intersection_count(intersections(i,3)) = line_intersection_count(intersections(i,3))+1;
        line_intersection_count(intersections(i,4)) = line_intersection_count(intersections(i,4))+1;
    end
end
intersections1 = intersections(:,3);
intersections2 = intersections(:,4);
for i = 1:size(lines,1)
    testVala = 0;
    testValb = 0;
    if (line_intersection_count(i))>1
        below_intersections = zeros(1,5);
        above_intersections = zeros(1,5);
        above_index = 1;
        below_index = 1;
        has_left_fulcrum = 0;
        has_right_fulcrum = 0;
        recheck = 1;
        xmid = round((lines(i,1)+lines(i,3))/2);
        ymid = round((lines(i,2)+lines(i,4))/2);
        [index1,col1] = find(intersections1==i);
        [index2,col2] = find(intersections2==i);
        result_index = union(index1,index2);
        for j=1:max(size(result_index,2),size(result_index,1))
            if (i==intersections(result_index(j),5))
                below_intersections(below_index,:) = round(intersections(result_index(j),:));
                below_index = below_index + 1;
                testValb = 1;
            else
                above_intersections(above_index,:) = round(intersections(result_index(j),:));
                above_index = above_index + 1;
                testVala = 1;
            end
        end
        if(testVala && testValb)
            furthest_left_fulcrum = [xmid,ymid];
            furthest_right_fulcrum = [xmid,ymid];
            for j = 1:size(below_intersections,1)
                if (below_intersections(j,1))<furthest_left_fulcrum(1,1)
                    furthest_left_fulcrum(1,:) = below_intersections(j,1:2);
                    has_left_fulcrum = 1;
                elseif (below_intersections(j,1))>furthest_right_fulcrum(1,1)
                    furthest_right_fulcrum(1,:) = below_intersections(j,1:2);
                    has_right_fulcrum = 1;
                elseif ((below_intersections(j,1) == xmid) && (below_intersections(j,2)<furthest_left_fulcrum(1,2)))
                    furthest_left_fulcrum(1,:) = below_intersections(j,1:2);
                    has_left_fulcrum = 1;
                elseif ((below_intersections(j,1) == xmid) && (below_intersections(j,2)>furthest_right_fulcrum(1,2)))
                    furthest_right_fulcrum(1,:) = below_intersections(j,1:2);
                    has_right_fulcrum = 1;
                end
            end
            while recheck
                recheck = 0;
                total_sum = sum(load_beared);
                total_left_sum = total_sum(3);
                total_right_sum = total_sum(4);
                current_left_sum = 0;
                current_right_sum = 0;
                for j = 1:size(above_intersections,1)
                    above_line = 0;
                    if (above_intersections(j,3)==i)
                        above_line = above_intersections(j,4);
                    else
                        above_line = above_intersections(j,3);
                    end
                    if (loadBearing(above_line,1)~=1)
                        if ((above_intersections(j,1)<furthest_left_fulcrum(1,1)) && has_left_fulcrum)
                            load_beared(i,1) = i;
                            load_beared(i,2) = load_beared(i,2)+1;
                            load_beared(i,3) = load_beared(i,3)+1;
                            if (load_beared(i,3) >= load_beared(i,4))
                                loadBearing(above_line,1)=1;
                                recheck = 1;
                            end
                        elseif ((above_intersections(j,1))>furthest_right_fulcrum(1,1) && has_right_fulcrum)
                            load_beared(i,1) = i;
                            load_beared(i,2) = load_beared(i,2)+1;
                            load_beared(i,4) = load_beared(i,4)+1;
                            if (load_beared(i,4) >= load_beared(i,3))
                                loadBearing(above_line,1)=1;
                                recheck = 1;
                            end
                        elseif (((above_intersections(j,1) == xmid) && (above_intersections(j,2)<furthest_left_fulcrum(1,2))) && has_left_fulcrum)
                            load_beared(i,1) = i;
                            load_beared(i,2) = load_beared(i,2)+1;
                            load_beared(i,3) = load_beared(i,3)+1;
                            if (load_beared(i,3) >= load_beared(i,4))
                                loadBearing(above_line,1)=1;
                                recheck = 1;
                            end
                        elseif (((above_intersections(j,1) == xmid) && (above_intersections(j,2)>furthest_right_fulcrum(1,2))) && has_right_fulcrum)
                            load_beared(i,1) = i;
                            load_beared(i,2) = load_beared(i,2)+1;
                            load_beared(i,4) = load_beared(i,4)+1;
                            if (load_beared(i,4) >= load_beared(i,3))
                                loadBearing(above_line,1)=1;
                                recheck = 1;
                            end
                        elseif (load_beared(i,3)>0)
                            if (above_intersections(j,1) > furthest_left_fulcrum(1,1))
                                current_right_sum = current_right_sum + 1;
                                if current_right_sum >= total_left_sum
                                    load_beared(i,2) = load_beared(i,2)+1;
                                    if (load_beared(i,4) <= total_left_sum)
                                        loadBearing(above_line,1)=1;
                                        recheck = 1;
                                    end
                                    load_beared(i,4) = load_beared(i,4)+1;
                                end
                            end
                        elseif (load_beared(i,4)>0)
                            if (above_intersections(j,1) < furthest_right_fulcrum(1,1))
                                current_left_sum = current_left_sum + 1;
                                if current_left_sum >= total_right_sum
                                    load_beared(i,2) = load_beared(i,2)+1;
                                    if (load_beared(i,3) <= total_right_sum)
                                        loadBearing(above_line,1)=1;
                                        recheck = 1;
                                    end
                                    load_beared(i,3) = load_beared(i,3)+1;
                                end
                            end
                        end
                    end
                end
            end
            %Calculate midpoint of line, calculate all tops intersections,
            %calculate all bottom intersections. If sum (top) and any bottom
            %same side, load bearing = y
        end
    end
end