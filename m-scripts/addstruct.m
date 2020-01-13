function s1 = addstruct(sa, sb, index)

% to add or insert a substructure to a structure 
%	    or to sort a structure
%
% addstruct(sa,sb)
% addstruct([],sb)		for sorting
% addstruct(sa,sb,index)	sa(index) = sb
%
% EXAMPLE
%
% sa.b = 2;  sb.a	= 10;
% sa.a = 1;  sb.b	= 20;
%
% sa	= addstruct(sa,sb,'([1 2])')
% sa	= addstruct(sa,sb,'(1:2, 1:4)')

% (C) 1999 Protys, www.protys.com\toolbox
% JdH
% library class 'structure manipulation'


%%%if nargin==1 & isstr(sa), addstruct_test, return, end

%%% if nargin<2, error('at least two input arguments required'), end

if ~isstruct(sb)
  % double [] can be regarded as empty structure, nothing to add
  s1	= sa;
  return
end

if ~isstruct(sa)
  s1		= sb;  
  
  if nargin>2
    s1		= s1([]);
    s1(index)	= sb;
  end
  return

elseif isempty(sa)
  % empty [0 * 0, 0 * 1, 1 * 0] structure
  fldNms	= fieldnames(sa);

  if numel(index) > 1
    for ii = 1:length(fldNms)
      [sa(index).(fldNms{ii})] = deal([]);
    end
  else
    for ii = 1:length(fldNms)
      sa(index).(fldNms{ii}) = [];
    end
  end
end

fb	= fieldnames(sb);

%%% if true && isequal(fieldnames(sa), fieldnames(sb))
%%% if isequal(fieldnames(sa), fieldnames(sb))
if isequal(fieldnames(sa), fb)
  % IdV accel: 20sep2007: verified that it makes it faster
  if nargin<3
    index	= 1;
  end
  s1		= sa;
  s1(index)	= sb;
  return
end

%%% f	= sort(fieldnames(sb)); % why sort???
f		= sort(fb); % why sort???

s1		= sa;

if nargin>2
  % check if array size of sb equals input 'index'
  %indexStr	= sprintf('(%d)', index);
  % indexStr	= sprintf(',%d', index);
  % indexStr	= ['(' indexStr(2:end) ')'];
  %%% for ii = 1:length(f)
  for ii = 1:numel(f)
    % disp(['[s1' indexStr '.' f{ii} '] = deal(sb.' f{ii} ');'])
    %eval(  ['[s1' indexStr '.' f{ii} '] = deal(sb.' f{ii} ');'])
    %eval(  ['s1' indexStr '.' f{ii} ' = sb.' f{ii} ';'])
    s1(index).(f{ii})	= sb.(f{ii});
  end

else
  % 
  %%% for ii = 1:length(f)
  for ii = 1:numel(f)
    %%% eval(  ['s1.' f{ii} ' = sb.' f{ii} ';'])
    s1.(f{ii}) 	= sb.(f{ii});
  end

end
end  % <base>

% =======================================================
%
%
%
function addstruct_test


a.b	= 2;
a.a	= 1;

disp([10 '========================='])
z=addstruct([],a)

b.a	= 10;
b.b	= 20;
a(2)	= a;

disp([10 '========================='])
z=addstruct(a,b)
disp([10 '========================='])
z=addstruct(a,b,'(2)')

c.c	= 3;
disp([10 '========================='])
d=addstruct(a,c,'(3,2)')

disp([10 '========================='])
z=addstruct(d,a,'(3,1:2)')

keyboard


%disp([10 '========================='])
%addstruct(a,b,':')
end