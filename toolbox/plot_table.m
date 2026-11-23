% Saves a ruled table (header row + one row per method) as <fname>.pdf/.png
% and as a LaTeX tabular <fname>.tex.  values(i,j) = row i, column j.
function plot_table(row_names, col_names, values, fname)

%% LaTeX
fid = fopen([fname '.tex'], 'w');
fprintf(fid, '\\begin{tabular}{l%s}\n\\hline\n', repmat('c', 1, numel(col_names)));
fprintf(fid, 'Method');
fprintf(fid, ' & %s', col_names{:});
fprintf(fid, '\\\\\n\\hline\n');
for i = 1:numel(row_names)
    fprintf(fid, '%s', row_names{i});
    fprintf(fid, ' & %.3f', values(i,:));
    fprintf(fid, '\\\\\n');
end
fprintf(fid, '\\hline\n\\end{tabular}\n');
fclose(fid);

%% Figure (10 pt, rules above and below the header and at the bottom)
fs = 10;
char_w = fs/72 * 0.60;                           % [in]
pad = 0.14;
row_h = fs/72 * 1.9;
col_w = [max(cellfun(@numel, [{'Method'}, row_names])), max(cellfun(@numel, col_names), 6)] * char_w + 2*pad;
x0 = [0 cumsum(col_w)];
W = x0(end);
H = (numel(row_names) + 1) * row_h;

fig = figure('Color', 'w', 'Units', 'inches', 'Position', [1 1 W H]);
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0 0 1 1]);
hold(ax, 'on');
axis(ax, [0 W 0 H]);
axis(ax, 'off');
set(ax, 'YDir', 'reverse');
y = @(r) (r - 0.5) * row_h;
txt = {'FontName', 'Times New Roman', 'FontSize', fs, 'VerticalAlignment', 'middle', 'Interpreter', 'none'};

text(ax, pad, y(1), 'Method', 'FontWeight', 'bold', txt{:});
for j = 1:numel(col_names)
    text(ax, x0(j+1) + col_w(j+1) - pad, y(1), col_names{j}, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'right', txt{:});
end
for i = 1:numel(row_names)
    text(ax, pad, y(i+1), row_names{i}, txt{:});
    for j = 1:numel(col_names)
        text(ax, x0(j+1) + col_w(j+1) - pad, y(i+1), sprintf('%.3f', values(i,j)), ...
             'HorizontalAlignment', 'right', txt{:});
    end
end
for yy = [0 row_h H]
    line(ax, [0 W], [yy yy], 'Color', 'k', 'LineWidth', 0.8);
end

exportgraphics(fig, [fname '.pdf'], 'ContentType', 'vector');
exportgraphics(fig, [fname '.png'], 'Resolution', 600);

end
