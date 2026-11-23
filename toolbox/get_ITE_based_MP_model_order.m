% ITE based MP model order estimation.
% inputs: 
% y - the measure signal 
% L - the pencil parameter
% M_max - the maximal hypothesized model order
% params - struct containing the necessary simulation parameters
function [M_opt_AIC, M_opt_MDL, M_opt_MAP, M_opt_EVT] = get_ITE_based_MP_model_order(y,L, M_max, sigma_w_2)

% number of parameter is pre-defined to be 4 - 
% initial phase, amplitude, damping factor and frequency
N_PARAMS = 4;

N = length(y);

AIC = zeros(M_max,1);
MDL = zeros(M_max,1);
MAP = zeros(M_max,1);
EVT = zeros(M_max,1);

y = y(:);
Y = hankel(y(1:N-L), y(N-L:N).');
    for M = 1: M_max
        % Estimate the parameters for a given model order
        [est_poles, est_amps] = get_mp_est(Y,y,N,M);
    
        % Compute the estimated signal
        y_hat = (est_poles(:).^(0:N-1)).' * est_amps(:);  % N-by-1

        % Compute log-likelihood
        logL = -N*log(pi*sigma_w_2) - (1/(sigma_w_2)) * norm(y_hat-y,2)^2;       

        % Number of parameters
        n = N_PARAMS * M; 
        AIC(M) = n - logL;
        MDL(M) = n*log(N) - 2*logL;
        MAP(M) = 5*M*log(N)-2*logL;
        alpha = 0.05;
        Cn = log(N) + 0.5*log(log(N))- 0.5*log(3*alpha^2/pi);
        EVT(M) = 2*M*Cn - 2*logL;
    end

    [~, M_opt_AIC] = min(AIC);
    [~, M_opt_MDL] = min(MDL);
    
    [~, M_opt_MAP] = min(MAP);
    [~, M_opt_EVT] = min(EVT);

end

function [z_hat, b_hat] = get_mp_est(Y,y,N,M)

    Y1 = Y(:,1:end-1);
    Y2 = Y(:,2:end);

    [U, S, V] = svd(Y1, 'econ');
    M = min(M, length(S));
    Ur = U(:, 1:M); 
    Sr = S(1:M, 1:M);
    Vr = V(:, 1:M);

    A =  Sr\(Ur')*Y2*Vr;

    [~, D] = eig(A);
    z_hat = diag(D);      
    
    b_hat  = pinv( z_hat.^(0:N-1).' )*y(:); 

end