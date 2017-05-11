function [ output] = GC_Score(Y, X, lags)
    %X-->Y
    x0 = X;
    y0 = Y;
    y1 = lagmatrix(Y, 1);
    output = zeros(lags, 1);

    for i = 1:lags
        x_lag = lagmatrix(x0, i);
        if (sum(~any(isnan([y0, y1, x_lag]), 2))) < 50 % at least 50 instances
            continue;
        end
        % regress with 1) only history data, 2) history data + data from
        % causer (X)
        [~, ~, r] = regress(y0, [y1 x_lag]);
        [~, ~, r0] = regress(y0, y1);
        var_e = nanvar(r);
        var_e0 = nanvar(r0);
        output(i) = (var_e0-var_e)/var_e0*sum(~isnan(r))/chi2inv(0.95, 1);
    end
end

