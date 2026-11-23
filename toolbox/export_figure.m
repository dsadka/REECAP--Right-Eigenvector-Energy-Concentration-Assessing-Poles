% Saves a figure as <fname>.pdf and a 600-dpi <fname>.png, page size = figure size.
function export_figure(fig, fname)

pos = get(fig, 'Position');
set(fig, 'PaperUnits', 'inches', 'PaperPositionMode', 'manual', ...
         'PaperSize', pos(3:4), 'PaperPosition', [0 0 pos(3:4)]);
print(fig, [fname '.pdf'], '-dpdf', '-painters');
print(fig, [fname '.png'], '-dpng', '-r600');

end
