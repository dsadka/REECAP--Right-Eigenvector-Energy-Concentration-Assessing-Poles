% One 1.8 x 1.6 in panel of AUC vs a sweep (one curve per method).
function plot_auc_panel(x, AUC, names, xlab, is_integer, y_lim, fname)

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 1.8 1.6]);
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.185 0.20 0.775 0.74]);
hold(ax, 'on');
for j = 1:numel(names)
    [style, color, face] = get_line_style(names{j});
    plot(ax, x, AUC(:,j), style, 'Color', color, 'MarkerFaceColor', face, ...
         'LineWidth', 1.1, 'MarkerSize', 2.5);
end
xlabel(ax, xlab);
ylabel(ax, 'AUC');
xlim(ax, [x(1) x(end)]);
ylim(ax, y_lim);
if is_integer
    xticks(ax, x);
end
box(ax, 'on');
grid(ax, 'on');
set(ax, 'GridLineStyle', ':', 'GridAlpha', 0.25, 'Layer', 'top');

export_figure(fig, fname);

end
