function [new_candidates, new_k_label] = Change_Structure(bnet, old_candidates, K, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, st_candidates, use_other_pollutants, neighbor_number)
   
    % prepare training data
    e_value = lagmatrix(e_data, e_t_lag);
    e_value = e_value(2:end, :);
    q_values = cell(1, K);
    for k = 1:K
        q_values{k} = Make_Q_Data(old_candidates, K, zeros(size(e_value, 1), 1) + k, p_data, q_t_lag, city, pollutant, use_other_pollutants);
    end
    p_value = diff(p_data(:, pollutant, city), 1);
    
    assert(size(e_value, 1) == size(q_values{1}, 1), string('training data size mismatch'));
    assert(size(e_value, 1) == size(p_value, 1), string('training data size mismatch'));

    % prepare training data for bayesian network
    mask = (~any(isnan(e_value), 2)) & (~any(isnan(p_value), 2));
    for k = 1:k
        mask = mask & (~any(isnan(q_values{k}), 2));
    end
    
    evidence = cell(4, 1);
    lls = zeros(size(e_value, 1), K);
    for k = 1:K
        q_value = q_values{k};
        for i = 1:length(mask)
            if mask(i)
                evidence{1} = k;
                evidence{2} = e_value(i,:)';
                evidence{3} = q_value(i,:)';
                evidence{4} = p_value(i,:)';
                [~, ll] = evalc('log_lik_complete(bnet, evidence);');
                lls(i, k) = ll;
            end
        end
    end
    [~, new_k_label] = max(lls, [], 2);
    new_k_label(~mask) = NaN;

    new_candidates = cell(K, 1);
    pollutant_type_count = size(p_data, 2);
    for k = 1:K
        tmp_candidates = st_candidates;
        index = (new_k_label == k);
        y = p_value(index);
        scores = NaN(size(tmp_candidates, 1), pollutant_type_count);
        for i = 1:size(tmp_candidates, 1)
            x_id = tmp_candidates(i, 1);
            for pollutant_x = 1:pollutant_type_count
                x = diff(p_data(:, pollutant_x, x_id), 1);
                score = max(GC_Score(y, x(index), length(q_t_lag)));
                scores(i, pollutant_x) = score;
            end
            if max(scores(i,:)) > 1
                new_candidates{k} = [new_candidates{k};[x_id, find(scores(i,:) == max(scores(i,:))), max(scores(i,:))]];
            end
        end
        if ~isempty(new_candidates{k})
            [~, sort_order]= sort(new_candidates{k}(:,3), 'descend');
            new_candidates{k} = new_candidates{k}(sort_order(1:min(neighbor_number,size(new_candidates{k},1))), :);
        else
            new_candidates{k} = [];
        end
end
