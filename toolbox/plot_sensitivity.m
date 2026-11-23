% Sensitivity figure: one dashed curve per hyperparameter value, colored along
% a turbo color bar on the right (no legend).  For the p sweep, the solid black
% curve is p = sp_depth(pMode).  Plot box 1.63 x 1.6 in, 13 pt text.
function plot_sensitivity(AUC, params, fname)

font_size = 13;
scale = font_size / 11;                          % margins grow with the font size
panel_w = 1.63;
panel_h = 1.6;
pad_left   = 0.185*panel_w*(scale - 1) + 0.01;   % room for the rotated 'AUC' label
pad_bottom = 0.20*panel_h*(scale - 1);
bar_strip  = 0.52*scale - 0.01;                  % color bar + its labels
fig_w = panel_w + bar_strip + pad_left;
fig_h = panel_h + pad_bottom;

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 fig_w fig_h]);
ax_pos = [(0.185*panel_w + pad_left)/fig_w, (0.20*panel_h + pad_bottom)/fig_h, ...
          0.775*panel_w/fig_w, 0.74*panel_h/fig_h];
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', ax_pos);
hold(ax, 'on');
set(ax, 'LabelFontSizeMultiplier', 1);

%% Curves
x = params.x;
vals = params.lines;
n_lines = numel(vals);
cmap = turbo(256);
colors = interp1(linspace(min(vals), max(vals), 256), cmap, vals(:));
for j = 1:n_lines
    plot(ax, x, AUC(:,j), '--', 'Color', colors(j,:), 'LineWidth', 0.8);
end
if params.has_bold
    plot(ax, x, AUC(:,end), '-', 'Color', [0 0 0], 'LineWidth', 1.1);
end

%% Axes
[xlab, is_integer] = get_sweep_label(params.x_var);
xlabel(ax, xlab);
ylabel(ax, 'AUC');
xlim(ax, [x(1) x(end)]);
ylim(ax, [0.4 1.02]);
yticks(ax, 0.4:0.2:1);

% Hide the last x tick label when it sits at the right edge
% (it clashes with the symbol under the color bar)
if is_integer
    ticks = x;
else
    drawnow;
    ticks = xticks(ax);
end
if is_integer || (x(end) - ticks(end)) <= 0.08*(x(end) - x(1))
    tick_labels = arrayfun(@(v) sprintf('$%g$', v), ticks, 'UniformOutput', false);
    tick_labels{end} = '';
    xticks(ax, ticks);
    xticklabels(ax, tick_labels);
end

box(ax, 'on');
grid(ax, 'on');
set(ax, 'GridLineStyle', ':', 'GridAlpha', 0.25, 'Layer', 'top');

%% Color bar
K_hat = ['K' char(770)];                         % K-hat in tex
switch params.sens_var
    case 'p'
        bar_labels = {sprintf('$%d$', min(vals)), sprintf('$%d$', max(vals))};
        if max(vals) == params.Khat_nominal
            bar_labels{2} = '$\hat{K}$';
        end
        symbol = 'p';
    case 'L'
        bar_labels = {'$\frac{N}{3}$', '$\frac{N}{2}$'};
        symbol = 'L';
    case 'Khat'
        bar_labels = {'$K$', '$L$'};
        symbol = K_hat;
end

colormap(ax, cmap);
caxis(ax, [min(vals) max(vals)]);
cb = colorbar(ax);
cb.TickLength = 0;
cb.TickLabelInterpreter = 'latex';
cb.FontSize = font_size;
cb.LineWidth = 0.6;
set(ax, 'Position', ax_pos);                     % colorbar() shrinks the axes
ax_right = (ax_pos(1) + ax_pos(3)) * fig_w;      % [in]
cb.Units = 'normalized';
cb.Position = [(ax_right + 0.04)/fig_w, ax_pos(2), 0.09/fig_w, ax_pos(4)];

% Put the two bar labels at the heights of the lowest and highest y ticks
yl = ylim(ax);
y_frac = ([0.4 1] - yl(1)) / (yl(2) - yl(1));
cb.Ticks = min(vals) + y_frac * (max(vals) - min(vals));
cb.TickLabels = bar_labels;

% Symbol under the color bar
sym_box = annotation(fig, 'textbox', [cb.Position(1) - 0.08, cb.Position(2) - 0.12, cb.Position(3) + 0.16, 0.09], ...
                     'String', symbol, 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'middle', 'Interpreter', 'tex', 'FontSize', font_size);

% Cut the empty space to the right of the bar labels
set([ax cb sym_box], 'Units', 'inches');
t = text(ax, 0, 0, 'x', 'Units', 'inches', 'Interpreter', 'latex', 'FontSize', font_size);
label_w = 0;
for k = 1:numel(bar_labels)
    t.String = bar_labels{k};
    label_w = max(label_w, t.Extent(3));
end
delete(t);
fig.Position(3) = cb.Position(1) + cb.Position(3) + 0.05 + label_w + 0.02;

%% Save
exportgraphics(fig, [fname '.pdf'], 'ContentType', 'vector');
exportgraphics(fig, [fname '.png'], 'Resolution', 600);

end
