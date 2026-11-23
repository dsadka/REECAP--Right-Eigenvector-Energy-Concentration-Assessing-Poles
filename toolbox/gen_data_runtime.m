% Mean run time [ms] vs N of s_p and the baselines (signal -> detected poles).
% Every method's time includes the shared matrix-pencil decomposition, except AIC
% and EVT, which compute their own decompositions for every order.
% The trials are run in rounds over all N in random order, so that a slow period
% of the machine is spread over every N.  Single-threaded for smooth timings.
function [T, T_decomp, params] = gen_data_runtime(pMode)

%% Settings
params = get_cluster_settings();
params.Nrep = 500;
params.SNR = 0;
params.granularity_factor = 2;                        % SAMP grid granularity
params.N_range = 41:20:241;
params.methods = {'REECAP', 'SAMP', 'SAMP++', 'Gap', 'SDD', 'ESTER', 'AIC', 'EVT', 'RIVES'};
own_decomposition = [false false false false false false true true false];   % AIC, EVT

nN = numel(params.N_range);
nM = numel(params.methods);
t_decomp  = zeros(params.Nrep, nN);
t_methods = zeros(params.Nrep, nM, nN);

prev_threads = maxNumCompThreads(1);
prev_stream = RandStream.getGlobalStream;
streams = cell(1, nN);                                % same signals as rng(seed) per N
for n = 1:nN
    streams{n} = RandStream('mt19937ar', 'Seed', params.seed);
end
order_stream = RandStream('mt19937ar', 'Seed', params.seed + 1);

% Warm-up run (not timed)
run_one_trial(params, params.N_range(1), pMode);

for rep = 1:params.Nrep
    for n = randperm(order_stream, nN)
        RandStream.setGlobalStream(streams{n});
        [t_decomp(rep,n), t_methods(rep,:,n)] = run_one_trial(params, params.N_range(n), pMode);
    end
    if mod(rep, 50) == 0
        disp(['round ', num2str(rep), '/', num2str(params.Nrep), ' done'])
    end
end

RandStream.setGlobalStream(prev_stream);
maxNumCompThreads(prev_threads);

% Mean over the trials, in ms
T_decomp = 1e3 * mean(t_decomp, 1).';
T = zeros(nN, nM);
for n = 1:nN
    T(n,:) = 1e3 * mean(t_methods(:,:,n), 1) + T_decomp(n) * ~own_decomposition;
end

end

function [t_decomp, t_methods] = run_one_trial(params, N, pMode)

L = floor(N * params.Lfrac);
[freqs, damps, amps, M, nClusters] = gen_cluster_poles(params, N);
[signal, ~, noise_var] = generate_sum_of_k_complex_exp_with_add_noise(freqs, damps, zeros(1,M), amps, ...
                                                                      params.dt, (N-1)*params.dt, params.SNR, params.noise);
[t_decomp, t_methods] = time_methods_one_trial(signal, L, noise_var, nClusters, pMode, params);

end
