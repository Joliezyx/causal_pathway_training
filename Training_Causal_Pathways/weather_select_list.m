% clear all; close all; clc;
% load CityInfo.mat
% load Station_Level_UD_Interp.mat
City_Num = size(CityInfo,1);

Nine_grid_weather = cell(City_Num,9);

LAT = StationInfo(:,2);
LONGI = StationInfo(:,3);
delta = 0.67;

for i = 1:City_Num
    Lat = CityInfo(i,2);
    Longi = CityInfo(i,3);
    count = 0;
    for j = -delta:delta:delta
        for k = -delta:delta:delta
            ind1 = find(LAT>=(2*j-1)+Lat & LAT <= (2*j+1)+Lat);
            ind2 = find(LONGI>=(2*k-1)+Longi & LONGI <= (2*k+1)+Longi);
            ind = intersect(ind1,ind2);
%             Station_ID = StationInfo(ind,1);
%             City_ID = unique(floor(Station_ID/1000));
            count = count+1;
            Nine_grid_weather{i,count} = ind;
        end
    end
end

save Nine_grid_weather.mat Nine_grid_weather;