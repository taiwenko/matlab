function N = isodatenum(V)
%ISODATEDUM Parse ISO date string
narginchk(1, 1);
N = datenum(V, 'yyyy-mm-ddTHH:MM:SS.FFF');
end
