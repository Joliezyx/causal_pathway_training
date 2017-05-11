function [bnet_trained, ll] = Train_Network(candidates, K, k_label, p_data, q_t_lag, e_data, e_t_lag, city, pollutant, use_other_pollutants)

    % prepare training data
    k_value = k_label;
    e_value = lagmatrix(e_data, e_t_lag);
    e_value = e_value(2:end, :);
    q_value = Make_Q_Data(candidates, K, k_label, p_data, q_t_lag, city, pollutant, use_other_pollutants);
    p_value = diff(p_data(:, pollutant, city), 1);
    
    assert(size(k_value, 1) == size(e_value, 1), string('training data size mismatch'));
    assert(size(k_value, 1) == size(q_value, 1), string('training data size mismatch'));
    assert(size(k_value, 1) == size(p_value, 1), string('training data size mismatch'));

    % construct bayesian network
    dag = zeros(4);
    dag(1, 2) = 1;
    dag(1, 4) = 1;
    dag(3, 4) = 1;
    discrete_nodes = [1];
    node_sizes = [K, size(e_value, 2), size(q_value, 2), 1];
    bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes);
    bnet.CPD{1} = tabular_CPD(bnet, 1);
    bnet.CPD{2} = gaussian_CPD(bnet, 2, 'cov_type', 'diag');
    bnet.CPD{3} = gaussian_CPD(bnet, 3);
    bnet.CPD{4} = gaussian_CPD(bnet, 4);

    % prepare training data for bayesian network
    mask = (~any(isnan(k_value), 2)) & (~any(isnan(e_value), 2)) & (~any(isnan(q_value), 2)) & (~any(isnan(p_value), 2));
    if sum(mask == 1) < 100
        ll = 0;   
        bnet_trained = bnet;
    else
        value = cell(4, sum(mask));
        value(1,:) = num2cell(k_value(mask,:)', 1);
        value(2,:) = num2cell(e_value(mask,:)', 1);
        value(3,:) = num2cell(q_value(mask,:)', 1);
        value(4,:) = num2cell(p_value(mask,:)', 1);
        bnet2 = learn_params(bnet, value);
        bnet_trained = struct(bnet2);
        [~, ll] = evalc('log_lik_complete(bnet2, value);');
    end
end