function str1 = strrepi(str, fnd, rpl)

% case insensitive string replace
%
% See also STRREP.

if iscell(str)
  str1	= str;	% init
  for cc = 1:prod(size(str))
    str1{cc}	= strrepi(str{cc}, fnd, rpl);
  end
  return
end

if length(fnd) > length(str)
  % 13-jul-2005: strrepi BUG removed
  str1	= str;
  return
end

% find smaller fnd in bigger str
ind	= findstr(lower(str), lower(fnd));
str1	= str;
L	= length(fnd);

for ii = ind(end:-1:1)
  % replace from end to keep indices valid
  str1	= [str1(1:ii-1) rpl str1(ii+L:end)];
end





