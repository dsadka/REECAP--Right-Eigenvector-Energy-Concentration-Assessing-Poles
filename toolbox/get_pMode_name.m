% Legend name of a depth rule p.
function name = get_pMode_name(pMode)

switch pMode
    case 'clusters',    name = 'p = #clusters';
    case 'elbow',       name = 'p = elbow';
    case 'elbow_accel', name = 'p = elbow (accel.)';
    case 'gap',         name = 'p = Gap';
    case 'sdd',         name = 'p = SDD';
    case 'fft',         name = 'p = FFT';
    otherwise,          name = ['p = ' pMode];
end

end
