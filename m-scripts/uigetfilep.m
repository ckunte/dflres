function [fl1,pd1] = uigetfilep(varargin)

%%pcwinonly%%	if only for pcwin version of Matlab
%%nocompile%%	if not compilable with Matlab Compiler

drawnow

% == parse
xypos		= {};
options		= [];
validopt	= {'initialdir','switchdir'};

% {option name, option value,...}	options

ii	= 0;
while ii < length(varargin)
  ii	= ii + 1;
  arg	= varargin{ii};
  if iscell(arg)
    % not a regular argument, do remove from varargin
    varargin(ii)	= [];
    ii	= ii - 1;

    % test for valid option
    propnm		= arg{1};
    propval		= arg{2};
    if any(strcmpi(validopt,propnm))
      options		= setfield(options,propnm,propval);
    end
  end
end

if isfield(options,'initialdir')
  % store original directory
  cd1	= cd;
  try
    cd(options.initialdir);
  end
end

[fl,pd]	= uigetfile(varargin{:});
drawnow

if nargout
  fl1	= fl;
end
if nargout>1
  pd1	= pd;
end

if ~fl
  if isfield(options,'initialdir')
    % return to original dirctory
    cd(cd1)
  end
  return
end

if findstr('yes',getsfield(options,'switchdir','no'))
  % pd may include ending '\'
  cd(pd)

elseif isfield(options,'initialdir')
  % return to original dirctory
  cd(cd1)

end

% extra
% =====
%
% inigroup:
% - where to find favorite directories
%
% changedirgui:
% - before uigetfile
% - with "switch to folder" toggle
% - add new folder to favourites
%
% favorites
% - group favorites
% - user favorites

