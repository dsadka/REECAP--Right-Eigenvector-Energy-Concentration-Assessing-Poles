% Marker/line style, color and marker face color of each curve (same in every figure).
function [style, color, face] = get_line_style(name)

switch name
    case 'REECAP',             style = '-o';  color = [0.00 0.45 0.74];
    case 'SAMP',               style = '--s'; color = [0.85 0.33 0.10];
    case 'SAMP++',             style = '--^'; color = [0.49 0.18 0.56];
    case 'SDD',                style = '-p';  color = [0.64 0.08 0.18];
    case 'Gap',                style = ':v';  color = [0.30 0.30 0.30];
    case 'ESTER',              style = '-h';  color = [0.00 0.60 0.50];
    case 'RIVES',              style = '-*';  color = [0.30 0.75 0.93];
    case 'AIC',                style = '-^';  color = [0.93 0.69 0.13];
    case 'EVT',                style = '->';  color = [0.47 0.67 0.19];
    case 'p = #clusters',      style = '-o';  color = [0.00 0.45 0.74];
    case 'p = elbow',          style = '--s'; color = [0.80 0.10 0.50];
    case 'p = elbow (accel.)', style = '-h';  color = [0.00 0.70 0.70];
    case 'p = Gap',            style = ':v';  color = [0.30 0.30 0.30];
    case 'p = SDD',            style = '-p';  color = [0.64 0.08 0.18];
    case 'p = FFT',            style = ':d';  color = [0.55 0.35 0.00];
end
face = color;
if strcmp(name, 'SAMP')
    face = 'w';                                    % open squares
end

end
