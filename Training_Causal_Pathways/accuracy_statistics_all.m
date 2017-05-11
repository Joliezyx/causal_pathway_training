clear all; close all; clc;
load City_Index.mat
load CityInfo.mat
N = 6;
K = 7;
iter_num = 3;
season = 1;
count_region = zeros(K,N,3);
optimal_neighbor_numbers = cell(1,3);
for p = 1:1
    for city = 1:3%size(CityInfo,1)
        accuracy_city = NaN(K,N,iter_num);
        fprintf('City %d', city);
        for ave_iter = 1:iter_num

            filename = strcat('./Result_new1/Accuracy/Season_',num2str(season),'_City_',num2str(city),'_Pollutant_',num2str(p),'_AveNo_',num2str(ave_iter),'.csv');                
            d=struct(dir(filename));
            if exist(filename, 'file') ==0 
                continue;
            end
            if d.bytes == 0 
                continue;
            end
            accuracy = csvread(filename);
            accuracy(accuracy <= 0) = NaN;
            if size(accuracy,1) ~= K || size(accuracy,2) ~= N
                continue;
            end
            accuracy_city(:,:,ave_iter) = accuracy;
%                 for k = 1:K   
%                     if max(accuracy_city(k,:)) < max(accuracy(k,:))                      
%                         accuracy_city(k,:) = accuracy(k,:);
%                     end
%                 end
        
        end
        accuracy_city = nanmean(accuracy_city,3)
        [maxA,ind] = max(accuracy_city(:));
        [m,n] = ind2sub(size(accuracy_city),ind);

        fprintf('--Optimal clusters %d, neighbor numbers %d, accuracy %f', m, n - 1, maxA);

        for test_city_index = 1:3
            if ismember(city,City_Index{test_city_index});
                fprintf('--Region %d\n', test_city_index);
                break;
            end
        end
        optimal_neighbor_numbers{test_city_index} = [optimal_neighbor_numbers{test_city_index}; [m, n]];
    end
end

save optimal_neighbor_numbers.mat optimal_neighbor_numbers