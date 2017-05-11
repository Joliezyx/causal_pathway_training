% update the parameters of GBNs for K clusters
warning off;
addpath(genpath('../bnt'));
clear all; close all; clc;
load City_Level_UD_Interp_New.mat;
load CityInfo.mat;
load training_ind_season_new.mat;
load ST_candidates_v1_new.mat;
load City_Level_Weather_Training.mat

mkdir('./Result_one_case');
mkdir('./Result_one_case/Log');
mkdir('./Result_one_case/Accuracy');
mkdir('./Result_one_case/Abs_Error');
mkdir('./Result_one_case/Candidates_New');

e_t_lag = 1; % time lag for environment data
q_t_lag = 1:2; % time lag for Q
pollutants = [1];

cities = [1]; %size(CityInfo,1);
seasons = 1:1; % seasons
pollutants_index = 2:7; % pollutants index in City_Level_UD
pollutants_type_count = length(pollutants_index);
use_other_pollutants = false;
neighbor_numbers = [2]; % number of neighbors you want to try
Ks = [4]; % K you want to try


current_time = datestr(clock,'YYYYmmDDhhMMss');
p_data_full = City_Level_UD(:, pollutants_index, :);

for pollutant = pollutants
    tic;
    for season = seasons
        index_training = ind_season{season};
        index_test = ind_season_test{season};
        for city = cities
            % rescaled the Environmental data, mean 0, std 1
            st_candidates = ST_candidates{pollutant, city, season};
            for neighbor_number = neighbor_numbers
                if neighbor_number > size(st_candidates, 1)
                    continue;
                end
                for K = Ks
                    p_data = p_data_full(index_training,:,:);
                    p_data_test = p_data_full(index_test,:,:);
                    % initialize candidates
                    candidates_count = min(size(st_candidates, 1) * pollutants_type_count, neighbor_number);
                    if candidates_count >= 0
                        candidates = cell(K,1);
                        for k = 1:K
                            candidates{k} = st_candidates(1:candidates_count, :);
                        end
                    else
                        fprint('neighbors < 0, error!');
                    end
                    q_value = Make_Q_Data(candidates, K, zeros(size(p_data, 1) - 1, 1) + 1, p_data, q_t_lag, city, pollutant, use_other_pollutants);
                    q_value_test = Make_Q_Data(candidates, K, zeros(size(p_data_test, 1) - 1, 1) + 1, p_data_test, q_t_lag, city, pollutant, use_other_pollutants);
                    p_value = diff(p_data(:, pollutant, city), 1);
                    p_value_test = diff(p_data_test(:, pollutant, city), 1);
                    
                    
                    % regression models
                    [b bint] = regress(p_value, q_value);
                    accuracy_LR = 1 - nanmean(abs(p_value_test - q_value_test*b)./p_data_test(2:end, pollutant, city))
                    
                    %arma_model = arima(2,0,3);
                    Mdl = fitrsvm(p_value, q_value);
                    Mdl.ConvergenceInfo.Converged
                end
            end
        end 
    end
    toc;
end




