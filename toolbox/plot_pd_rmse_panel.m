% One 1.85 x 1.6 in panel of p_d or RMSE vs SNR / spacing (one curve per method).
% crb : CRB curve to overlay (same units as Y), or [] for none.
function plot_pd_rmse_panel(x, Y, names, xlab, ylab, y_lim, crb, fname)

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 1.85 1.6]);
ax = axes('Parent', fig, 'Units', 'normalized', ...
          'Position', [(0.185*1.8 + 0.05)/1.85, 0.20, 0.775*1.8/1.85, 0.74]);
hold(ax, 'on');
for j = 1:numel(names)
    [style, color, face] = get_line_style(names{j});
    plot(ax, x, Y(:,j), style, 'Color', color, 'MarkerFaceColor', face, ...
         'LineWidth', 0.8, 'MarkerSize', 2.5);
end
if ~isempty(crb)
    plot(ax, x, crb, '-.', 'Color', [0 0 0], 'LineWidth', 1.1, 'Marker', 'none');
end
xlabel(ax, xlab);
ylabel(ax, ylab);
xlim(ax, [x(1) x(end)]);
ylim(ax, y_lim);
box(ax, 'on');
grid(ax, 'on');
set(ax, 'GridLineStyle', ':', 'GridAlpha', 0.25, 'Layer', 'top');

export_figure(fig, fname);

end
