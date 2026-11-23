% Run time vs N on a log scale (3.0 x 2.4 in), solid lines.
% T_decomp (shared decomposition) is only used to set the y-axis range.
function plot_runtime(N_range, T, T_decomp, names, fname)

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 3.0 2.4]);
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.165 0.165 0.80 0.80]);
hold(ax, 'on');
set(ax, 'YScale', 'log');
for j = 1:numel(names)
    [style, color] = get_line_style(names{j});
    plot(ax, N_range, T(:,j), ['-' style(end)], 'Color', color, 'MarkerFaceColor', color, ...
         'LineWidth', 1.1, 'MarkerSize', 2.5);
end
xlabel(ax, 'number of samples N');
ylabel(ax, 'time [ms]');
xlim(ax, [N_range(1) N_range(end)]);

% Decade ticks (1, 10, 100, ...) around the data
v = [T(:); T_decomp(:)];
v = v(isfinite(v) & v > 0);
ticks = 10.^(floor(log10(min(v))) : ceil(log10(max(v))));
set(ax, 'YLim', [min(v)/1.4, max(v)*1.4], 'YTick', ticks, ...
        'YTickLabel', arrayfun(@num2str, ticks, 'UniformOutput', false), ...
        'YMinorTick', 'on', 'YMinorGrid', 'off');

box(ax, 'on');
grid(ax, 'on');
set(ax, 'GridLineStyle', ':', 'GridAlpha', 0.25, 'Layer', 'top');

export_figure(fig, fname);

end
