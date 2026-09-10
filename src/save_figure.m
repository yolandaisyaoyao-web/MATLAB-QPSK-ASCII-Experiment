function save_figure(fig, pathBase)
%SAVE_FIGURE Save an editable FIG and a report-ready 300 DPI PNG.

if ~isgraphics(fig, 'figure')
    error('qpsk:InvalidFigure', 'The first input must be a figure handle.');
end

savefig(fig, [pathBase '.fig']);
exportgraphics(fig, [pathBase '.png'], 'Resolution', 300);
close(fig);
end
