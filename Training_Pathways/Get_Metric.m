function [abs_err, accuracy] = Get_Metric(bnet, candidates, K, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, use_other_pollutants)
    e_value = lagmatrix(e_data, e_t_lag);
    e_value = e_value(2:end, :);
    mask = ~any(isnan(e_value), 2);
    k_label = NaN(length(mask), 1);
    cpd2_mean = struct(bnet.CPD{2}).mean';
    cpd2_cov = struct(bnet.CPD{2}).cov;
    for i = 1:length(mask)
        if mask(i)
            [~, k_label(i)] = max(mvnpdf(e_value(i,:), cpd2_mean, cpd2_cov));
        end
    end
    k_value = k_label;
    q_value = Make_Q_Data(candidates, K, k_label, p_data, q_t_lag, city, pollutant, use_other_pollutants);
    p_value = diff(p_data(:, pollutant, city), 1);

    assert(size(k_value, 1) == size(e_value, 1), string('training data size mismatch'));
    assert(size(k_value, 1) == size(q_value, 1), string('training data size mismatch'));
    assert(size(k_value, 1) == size(p_value, 1), string('training data size mismatch'));

    engine = jtree_inf_engine(bnet);
    mask = (~any(isnan(k_value), 2)) & (~any(isnan(e_value), 2)) & (~any(isnan(q_value), 2)) & (~any(isnan(p_value), 2));
    evidence = cell(4, 1);
    predict_value = NaN(length(mask), 1);
    for i = 1:length(mask)
        if mask(i)
            evidence{1} = k_value(i);
            evidence{2} = e_value(i,:)';
            evidence{3} = q_value(i,:)';
            [engine2, ~] = enter_evidence(engine, evidence);
            tmp = marginal_nodes(engine2, 4);
            predict_value(i) = tmp.mu;
        end
    end
    abs_err = nansum(abs(predict_value - p_value)) / sum(~isnan(predict_value - p_value));
    accuracy = 1 - nanmean(abs(predict_value - p_value)./p_data(2:end, pollutant, city));
end