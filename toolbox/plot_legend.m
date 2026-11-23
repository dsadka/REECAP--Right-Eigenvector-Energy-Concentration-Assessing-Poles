% Stand-alone horizontal legend (5.2 in wide) for the curves in names.
% add_crb = true adds the dash-dot CRB line as the last entry.
% solid = true draws every entry as a solid line with filled markers (run-time figure).
function plot_legend(names, n_cols, font_size, add_crb, fname, solid)

if nargin < 6
    solid = false;
end

n = numel(names) + add_crb;
leg_h = 0.22 + 0.20 * ceil(n / n_cols);
fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 5.2 leg_h]);
ax = axes('Parent', fig);
hold(ax, 'on');

h = gobjects(1, n);
for j = 1:numel(names)
    [style, color, face] = get_line_style(names{j});
    if solid
        style = ['-' style(end)];
        face = color;
    end
    h(j) = plot(ax, nan, nan, style, 'Color', color, 'MarkerFaceColor', face, ...
                'LineWidth', 1.1, 'MarkerSize', 2.5);
end
labels = names;
if add_crb
    h(n) = plot(ax, nan, nan, '-.', 'Color', [0 0 0], 'LineWidth', 1.4);
    labels = [labels, {'CRB'}];
end

lg = legend(ax, h, labels, 'Orientation', 'horizontal', 'NumColumns', n_cols, ...
            'FontSize', font_size, 'Box', 'off');
axis(ax, 'off');
lg.Units = 'normalized';
lg.Position = [0.5 - lg.Position(3)/2, 0.5 - lg.Position(4)/2, lg.Position(3), lg.Position(4)];

export_figure(fig, fname);

end
