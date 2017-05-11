% p_data : t * pollutant_type_count * city_count
function q_data = Make_Q_Data(candidates_new, K, k_label, p_data, q_t_lag, city, pollutant, use_other_pollutants)
    assert(length(k_label) == size(p_data, 1)-1, string('label length should be one less than p_data length'));
    pollutant_type_count = size(p_data, 2);
    candidates = cell(K,1);
    length_candidates_pollutants = 0; 
    for k = 1:K
        if isempty(candidates_new{k})
            candidates{k} = [];
        else
            candidates_count = size(candidates_new{k},1);
            [~, sort_order] = sort(candidates_new{k}(:, 3), 'descend');
            candidates{k} = (candidates_new{k}(sort_order(1:candidates_count), 1)-1) * pollutant_type_count +  candidates_new{k}(sort_order(1:candidates_count),2);
            if length(candidates{k}) > length_candidates_pollutants
                length_candidates_pollutants = length(candidates{k}); %candidates could be less than neighbor numbers
            end
        end
    end
    row_count = length(k_label);
    if use_other_pollutants
        column_count = (pollutant_type_count + length_candidates_pollutants) * length(q_t_lag);
    else
        column_count = (1 + length_candidates_pollutants) * length(q_t_lag);
    end
    q_data = NaN(row_count, column_count);
    for k = 1:K
        tmp_q_data = NaN(size(p_data, 1), 1 + length(candidates{k}));
        if use_other_pollutants
            tmp_q_data(:, 1:pollutant_type_count) = p_data(:,:, city);
        else
            tmp_q_data(:, 1) = p_data(:, pollutant, city);
        end
        for i = 1:length(candidates{k})
            candidate = candidates{k}(i);
            city_candidate = div(candidate-1, pollutant_type_count) + 1;
            pollutant_candidate = mod(candidate-1, pollutant_type_count) + 1;
            if use_other_pollutants
                tmp_q_data(:, pollutant_type_count+i) = p_data(:, pollutant_candidate, city_candidate);
            else
                tmp_q_data(:, 1+i) = p_data(:, pollutant_candidate, city_candidate);
            end
        end
        tmp_q_data = lagmatrix(diff(tmp_q_data, 1), q_t_lag);
        index = (k_label == k);
        if size(q_data,2) > size(tmp_q_data,2)
            q_data(index,1:size(tmp_q_data,2)) = tmp_q_data(index,:);
            for temp_column = (size(tmp_q_data,2) + 1):size(q_data,2)
                q_data(index,temp_column) = tmp_q_data(index,1 + mod(temp_column - 1,size(tmp_q_data,2)));
            end
        else
            q_data(index,:) = tmp_q_data(index,:);
        end
    end
end