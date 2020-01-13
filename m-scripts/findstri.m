function out = findstri(varargin)

% case insensitive version of findstr
%
%    K = FINDSTR(S1,S2) returns the starting indices of any occurrences
%    of the shorter of the two strings in the longer.
%
% See also FINDSTR, STRCMP, STRCMPI


% (C) 2001 Protys, www.protys.com\toolbox
% JdH

args	= lower(varargin);

out	= findstr(args{:});

end

