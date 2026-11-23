## REECAP: Right Eigenvector Energy Concentration for Assessing candidate Poles. Detection of Clustered Matrix Pencil Poles

The MATLAB code in this repository reproduces the numerical results of the REECAP s_p detection score for
clustered poles. For each matrix-pencil pole i, the score is s_p(i) = sum_{l<=p} |q_i(l)|^2, where q_i is the i'th eigenvector of the reduced pencil.

To reproduce the figures, download the 's_p' and 'toolbox' folders and run the files in the 's_p' folder.
The figures are saved to a 'figures' folder next to them.

| Script | Figures |
|---|---|
| `detection_auc_vs_baselines.m` | Figure 2: Detection AUC of s_p vs SAMP, SAMP++, SDD, Gap, ESTER and RIVES (sweeps of SNR, N, number of clusters, poles per cluster, pole spacing and damping) |
| `pd_rmse_vs_baselines.m` | Figure 3: p_d (a, c) and frequency RMSE with the CRB (b, d) of s_p and the baselines, vs SNR (a, b) and pole spacing (c, d) |
| `hyperparameter_sensitivity.m` | Figure 4, 7, 8: Sensitivity of s_p to p, L and the working rank K-hat |
| `detection_auc_p_rules.m` | Figure 6: Detection AUC of s_p for different rules of choosing p |
| `pd_auc_noise_table.m` | Table: area under the p_d-vs-SNR curve under normal and bi-normal noise |
| `runtime_vs_N.m` | Figure 5: Run time of s_p and the baselines vs N |

Settings at the top of each script:
- `pMode` : how p is chosen (`'clusters'` = true number of clusters, `'elbow'`, `'elbow_accel'`, `'fft'`, ... see `toolbox/sp_depth.m`)
- `sweeps` / `sweep_var` / `x_var` / `sens_var` : which sweeps to run

Requires MATLAB R2020a or later (`matchpairs`, `exportgraphics`, `turbo`) and the Statistics and Machine
Learning Toolbox (`kmeans`, used in `runtime_vs_N.m`).
