% update the parameters of GBNs for K clusters
warning off;
addpath(genpath('../bnt'));
clear all; close all; clc;
load City_Level_UD_Interp_New.mat;
load CityInfo.mat;
load training_ind_season_new.mat;
load ST_candidates_v1_new.mat; %v1 - pattern mining + granger causlaity, v2 - only granger causality
load City_Level_Weather_Training.mat

mkdir('./Result');
mkdir('./Result/Log');
mkdir('./Result/Accuracy');
mkdir('./Result/Abs_Error');
mkdir('./Result/Candidates_New');

e_t_lag = 1; % time lag for environment data
q_t_lag = 1:2; % time lag for Q
pollutants = 1:6;
iters = [1,2,3];
cities = 1:size(CityInfo,1);
seasons = 1:4; % seasons
pollutants_index = 2:7; % pollutants index in City_Level_UD
pollutants_type_count = length(pollutants_index);
use_other_pollutants = false;
neighbor_numbers = 0:5; % number of neighbors you want to try
Ks = 1:7; % K you want to try
em_iter_num = 10;

current_time = datestr(clock,'YYYYmmDDhhMMss');
p_data_full = City_Level_UD(:, pollutants_index, :);

for pollutant = pollutants
    tic;
    for season = seasons
        index_training = ind_season{season};
        index_test = ind_season_test{season};
        for iter = iters
            for city = cities
                % rescaled the Environmental data, mean 0, std 1
                e_data_tmp = City_Level_Weather_Training{city};
                e_data_standardized = (e_data_tmp - repmat(nanmean(e_data_tmp(index_training,:)),size(e_data_tmp,1),1)) ./ repmat(nanstd(e_data_tmp(index_training,:)),size(e_data_tmp,1),1);
                st_candidates = ST_candidates{pollutant, city, season};
                file_name = strcat('./Result/Log/Season_', num2str(season), '_City_', num2str(city), '_Pollutant_', num2str(pollutant), '_AveNo_', num2str(iter), '.txt');
                file_name_2 = strcat('./Result/Abs_Error/Season_', num2str(season), '_City_', num2str(city), '_Pollutant_', num2str(pollutant), '_AveNo_', num2str(iter), '.csv');
                file_name_3 = strcat('./Result/Accuracy/Season_', num2str(season), '_City_', num2str(city), '_Pollutant_', num2str(pollutant), '_AveNo_', num2str(iter), '.csv');
                abs_errs = zeros(length(Ks), length(neighbor_numbers));
                accuracies = zeros(length(Ks), length(neighbor_numbers));
                ST_candidates_refined = cell(length(Ks), length(neighbor_numbers), em_iter_num);
                klabels_refined = cell(length(Ks), length(neighbor_numbers), em_iter_num);
                f = fopen(file_name, 'w');
                % f = 1; % redirect output to stdout
                for neighbor_number = neighbor_numbers
                    if neighbor_number > size(st_candidates, 1)
                        continue;
                    end
                    for K = Ks
                        e_data = e_data_standardized(index_training,:);
                        remove_index_e_data = ~any(~isnan(e_data), 1);
                        e_data(:, remove_index_e_data)=[]; % remove columns with all nan
                        p_data = p_data_full(index_training,:,:);

                        %initialize k_label
                        k_label = kmeans(e_data, K);
                        k_label = k_label(2:end);

                        % initialize candidates
                        candidates_count = min(size(st_candidates, 1), neighbor_number);
                        if candidates_count >= 0
                            candidates = cell(K,1);
                            for k = 1:K
                                candidates{k} = st_candidates(1:candidates_count, :);
                            end
                        else
                            fprint('neighbors < 0, error!');
                        end

                        [bnet, ll] = Train_Network(candidates, K, k_label, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, use_other_pollutants);
                        fprintf(f, 'LL initialize: %f\n', ll);                        
                        lls = zeros(em_iter_num, 1);
                        jump_testing = 0;
                        for em_iter = 1:em_iter_num
                            [candidates, k_label] = Change_Structure(bnet, candidates, K, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, st_candidates, use_other_pollutants, neighbor_number);
                            [bnet, lls(em_iter)] = Train_Network(candidates, K, k_label, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, use_other_pollutants);
                            if lls(em_iter) == 0
                                fprintf(f, 'LL round %d: too few data, failed~\n', em_iter);
                                jump_testing = 1;
                                break;
                            end
                            fprintf(f, 'LL round %d: %f\n', em_iter, lls(em_iter));
                            fprintf(f, 'Change Structure Iteration: %d\n', em_iter);
                            for k = 1:K
                                fprintf(f,'Candidates for cluster %d: ', k);
                                fprintf(f,'%d ', candidates{k});
                                fprintf(f,'\n');
                            end
                            fprintf(f, '\n');
                            ST_candidates_refined{K - Ks(1) + 1, neighbor_number - neighbor_numbers(1) + 1, em_iter} = candidates;
                            klabels_refined{K - Ks(1) + 1, neighbor_number - neighbor_numbers(1) + 1, em_iter} = k_label;
                        end % end for EM_iter
                        fprintf(f, 'Log Likelihoods:');
                        fprintf(f, ' %f', [ll;lls]);
                        fprintf(f, '\n');
                        
                        % testing
                        if jump_testing == 1
                            fprintf('Pollutant %d, City %d, N %d, K %d, Jumped due to few data~\n', pollutant, city, neighbor_number, K);
                            continue;
                        end
                        e_data_test = e_data_standardized(index_test,:);
                        e_data_test(:,remove_index_e_data) = [];
                        e_data = e_data_test;
                        p_data = p_data_full(index_test,:,:);
                        [abs_err, accuracy] = Get_Metric(bnet, candidates, K, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, use_other_pollutants);
                        fprintf(f,'Pollutant %d, City %d, N %d, K %d, ABS_Error:%f\n', pollutant, city, neighbor_number, K, abs_err);
                        fprintf(f, '===================================\n');
                        fprintf('Pollutant %d, City %d, N %d, K %d, ABS_Error:%f\n', pollutant, city, neighbor_number, K, abs_err);
                        fprintf('Pollutant %d, City %d, N %d, K %d, Accuracy:%f\n', pollutant, city, neighbor_number, K, accuracy);
                        abs_errs(K - Ks(1) + 1, neighbor_number - neighbor_numbers(1) + 1) = abs_err;
                        accuracies(K - Ks(1) + 1, neighbor_number - neighbor_numbers(1) + 1) = accuracy;             
                    end % end for K
                end % end for neighbor_number
                fprintf(f, '\n');
                fclose(f);
                csvwrite(file_name_2,abs_errs);
                csvwrite(file_name_3,accuracies);
                matname = strcat('./Result/Candidates_New/City_',num2str(city),'_Season_',num2str(season),'_Pollutant_', num2str(pollutant), '_AveNo_', num2str(iter), '.mat');
                save(fullfile(matname),'ST_candidates_refined','klabels_refined');
                pause(20);
            end
        end
    end
    toc;
end




