clear all; close all; clc;
load CityInfo.mat;
load City_Index.mat;
%load City_Level_UD_Interp.mat;
load Station_Level_UD_Interp_New.mat;
load Nine_grid_weather.mat
% border = Region_range(3,:); %1: NC, 2:YRC, 3:PRD
% Region_Index = City_Index{3}; %1: NC, 2:YRC, 3:PRD


City_Num = size(CityInfo,1);
Window_Length = size(Station_Level_Weather,1);

tic;
City_Level_Weather_Training = cell(City_Num,1);
for i = 1:City_Num
    fprintf('City ID: %d.\n',i);
    City_Level_Weather_Training{i} = [];
    for j = 1:9
        ind = Nine_grid_weather{i,j};
        if ~isempty(ind)
            City_Level_Weather_Training{i} = [City_Level_Weather_Training{i} nanmean(Station_Level_Weather(:,3:7,ind),3)];
        end        
    end
end

toc;

save City_Level_Weather_Training.mat City_Level_Weather_Training
