% Generate training and testing indices

clear all; close all; clc;
load City_Level_UD_Interp_New.mat;
% load CityInfo.mat;
load ind_season_new.mat


% generate timestamps of testing data

breakpoint = {'2014-Apr-01';'2014-Jul-01';'2014-Oct-01';...
    '2015-Jan-01';'2015-Apr-01';'2015-Jul-01';'2015-Oct-01';'2016-Jan-01';...
    '2016-Apr-01';'2016-Jul-01';'2016-Oct-01';'2016-Dec-31'};

timestamp = City_Level_UD(:,1,1);
ind = cell(size(breakpoint,1),1);
for i = 1:size(breakpoint,1)
    ind{i} = find(timestamp == datenum(breakpoint(i),'yyyy-mmm-dd'));
    
end

ind_season_test = cell(4,1);
ind_season_test{1} = cat(2,ind{1}-24*15:ind{1},ind{5}-24*15:ind{5},ind{9}-24*15:ind{9})'; %half a month 2014 - half a month 2016
ind_season_test{2} = cat(2,ind{2}-24*15:ind{2},ind{6}-24*15:ind{6},ind{10}-24*15:ind{10})';
ind_season_test{3} = cat(2,ind{3}-24*15:ind{3},ind{7}-24*15:ind{7},ind{11}-24*15:ind{11})';
ind_season_test{4} = cat(2,ind{4}-24*15:ind{4},ind{8}-24*15:ind{8},ind{12}-24*15:ind{12})';

ind_season{1} = setdiff(ind_season{1},ind_season_test{1});
ind_season{2} = setdiff(ind_season{2},ind_season_test{2});
ind_season{3} = setdiff(ind_season{3},ind_season_test{3});
ind_season{4} = setdiff(ind_season{4},ind_season_test{4});


save training_ind_season_new.mat ind_season ind_season_test

% %==========================================================================
% % don't use the following codes!!
% 
% % prepare the original data in city level (or city level)
% [A B C] = size(City_Level_UD);
% 
% K = 2; % number of clusters
% N = 9; % number of neighbors
% Tlag = 2; % number of timelags
% 
% Precision = cell(K,N);
% 
% Training_Data = cell(3,1);
% Testing_Data = cell(3,1);
% 
% 
% % define the datasets for air pollutants and environmental factors
% P = [];
% E = [];
% P_Test = [];
% E_Test = [];
% P_Value = [];
% 
% 
% % Prepare training datasets
% for i = 1:C
%     fprintf('Training data: %d - th city\n', i);
%     for Up_Down = 1:2   % change the data to increasing cases & decreasing cases
%         temp_neighbor_index = Neighbor_Index{i,Up_Down};
%         if size(temp_neighbor_index,1) == 0
%             continue;
%         end
%         if size(temp_neighbor_index{1,1},1) == 0 
%             continue;
%         end
%         for j = 1:size(temp_neighbor_index,1)
%             temp_timestamps = temp_neighbor_index{j,2};
%             temp_neighbor = temp_neighbor_index{j,1};
% 
%             % generate data for air pollutants
%             XLAG = [];
%             for t = 0:Tlag
%                 XLAG = [XLAG UD(temp_timestamps - t,2:7,i)];
%             end
%             for nn = 1:N
%                 for t = 1:Tlag
%                     XLAG = [XLAG UD(temp_timestamps - t,2:7,temp_neighbor(nn))];
%                 end
%             end
% 
%             window_index = repmat([i Up_Down j],size(XLAG,1)-1,1);
%             XLAG = [diff(XLAG) window_index];
%             P = [P;XLAG];
% 
%             % generate data for weather
%             XLAG = [];
%             for t = 0:Tlag
%                 XLAG = [XLAG UD(temp_timestamps - t,[9,11,12,13],i)];
%             end
%             for nn = 1:N
%                 for t = 1:Tlag
%                     XLAG = [XLAG UD(temp_timestamps - t,[9,11,12,13],temp_neighbor(nn))];
%                 end
%             end
%             XLAG = [diff(XLAG) window_index];
%             E = [E;XLAG];
%         end
% 
%     end
% end
% 
% 
% for i = 1:C
%     fprintf('Testing data: %d - th city\n', i);
%     for Up_Down = 1:2   % change the data to increasing cases & decreasing cases
% 
%         temp_neighbor_index = Neighbor_Index_Test{i,Up_Down};
%         if size(temp_neighbor_index,1) == 0
%             continue;
%         end
%         if size(temp_neighbor_index{1,1},1) == 0
%             continue;
%         end
%         for j = 1:size(temp_neighbor_index,1)
%             temp_timestamps = temp_neighbor_index{j,2};
%             temp_neighbor = temp_neighbor_index{j,1};
% 
%             % generate data for air pollutants
%             XLAG = [];
%             for t = 0:Tlag
%                 XLAG = [XLAG UD_Test(temp_timestamps - t,2:7,i)];
%             end
%             for nn = 1:N
%                 for t = 1:Tlag
%                     XLAG = [XLAG UD_Test(temp_timestamps - t,2:7,temp_neighbor(nn))];
%                 end
%             end
% 
%             
%             window_index = repmat([i Up_Down j],size(XLAG,1)-1,1);
%             P_Value = [P_Value;XLAG(1:end-1,:) window_index temp_timestamps(1:end-1)];
%             XLAG = [diff(XLAG) window_index];
%             P_Test = [P_Test;XLAG];
% 
%             % generate data for weather
%             XLAG = [];
%             for t = 0:Tlag
%                 XLAG = [XLAG UD_Test(temp_timestamps - t,[9,11,12,13],i)];
%             end
%             for nn = 1:N
%                 for t = 1:Tlag
%                     XLAG = [XLAG UD_Test(temp_timestamps - t,[9,11,12,13],temp_neighbor(nn))];
%                 end
%             end
%             XLAG = [diff(XLAG) window_index];
%             E_Test = [E_Test;XLAG];
%         end
% 
%     end
% end
% 
% 
% save Training_Data.mat P E P_Test E_Test P_Value








