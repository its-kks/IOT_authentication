function [distance] = distance(ecef_1,ecef_2)
    % return distance between two points
    distance = sqrt((ecef_1(1)-ecef_2(1))^2+(ecef_1(2)-ecef_2(2))^2+(ecef_1(3)-ecef_2(3))^2);
end

