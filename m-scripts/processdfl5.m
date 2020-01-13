function out = processdfl5(varargin)
% function: process dynfloat timeseries (multiple seeds)
% 
% $HvZ January 2008
% ck updated to produce 5th highest (instead of the 3rd highest.) Dec 2008

out = [];

if ~nargin
pd0             = pwd;
% following line commented out - not working in Octave.
%currentdatadir('changeto')
[fl,pd] = uigetfile('*.RES*','Open Dynfloat response file *.RES	','MultiSelect', 'on');
cd(pd0)

%if ~any(fl)
  % when uigetfile is cancelled it returns 0
%  return
%end

if ischar(fl)
  fl            = {fl};
end

% ------------------------------------------------------------------------
dfld    = [];
tso     = [];

for ff = 1:length(fl)
  flNm_ff               = [pd fl{ff}];
%  dfld_ff              = readres(flNm_ff, '-notso');
  dfld_ff               = readres(flNm_ff);
  dfld                  = addstruct(dfld, dfld_ff, ff);
  dflf(ff).flNm         = flNm_ff;
%%  tso                 = addstruct(tso, tso_ff, ff);
end
% ------------------------------------------------------------------------

matfl           = strrepi(fl{1}, '.res','_all.mat');
matFlNm         = fullfile(pd, matfl);

save(matFlNm, 'dfld');
fprintf(1, '\nMat file saved to %s\n', matFlNm)

assignin('base', 'dfld', dfld);

processdfl5(dfld);
return
end 

dfld    = varargin{1};


% +++ STATISTICS +++
for ff = 1:length(dfld)
  % print file names of f
  fprintf(1, '%s\n', dfld(ff).flNm);
end

responses       = {'F_mline'};
inds            = find(strncmpi('F_mline',{dfld(1).signals.dlfName},7));

fprintf(1,'\n')
fprintf(1, 'Max Line Tension (kN)\t Mean\tStd\tall for Line nr\t%%MBL');
valueM          = zeros(length(dfld), 3) + NaN;
for ff = 1:length(dfld)
  [value(1), lineInd]           = max(dfld(ff).stats.max(inds));
  value(2)                      = dfld(ff).stats.mean(inds(lineInd));
  value(3)                      = dfld(ff).stats.std(inds(lineInd));
%  value(4)                     = value(3)/value(2);
%   mbl                         = value(1)/22800 * 100;
  fprintf(1, '\n %8.0f \t%8.0f \t%8.0f \t %d', value(1), value(2), value(3), lineInd)
  valueM(ff,:)                  = value;
end

valueM_sorted           = sort(valueM);

% if length(dfld)>=5
% fprintf(1, '\n')
% fprintf('Fifth highest value\n')
% fprintf('max\tmean\tstd\n')
% fprintf(1, '%8.0f\t', valueM_sorted(end-4,:))
% fprintf(1,'\n')
% end


if length(dfld)>=5
fprintf(1, '\n')
fprintf('Fifth highest value\n')
fprintf('max\tmean\tstd\n')
fprintf(1, '%8.0f\t', valueM_sorted(end-4,:))
fprintf(1,'\n')
end


fprintf(1,'\n')
fprintf(1, 'Turret Loads\n')
fprintf(1,'max Fx(kN)\tmin Fx(kN)\tmax(abs(Fx))(kN)\tmax Fy (kN)\tmin Fy (kN)\tmax(abs(Fx))(kN)\tmax Fz(kN)\tmin Fz(kN)\tmax(abs(Fx))(kN)\tmax Mk(kN)\tmin Mk(kN)\tmax(abs(Fx))(kN)\tmax Mm(kN)\tmin Mm(kN)');

signals = {
  'F_turret_X'
  'F_turret_Y'
  'F_turret_Z'
  'F_turret_K'
  'F_turret_M'
  };

for ss = 1:length(signals)
ind(ss)         = find(strncmpi(signals{ss},{dfld(1).signals.dlfName},10));
end

valueM          = zeros(length(dfld), length(signals)*3) + NaN;
for ff = 1:length(dfld)
  for ss = 1:length(signals)
  val1                  = dfld(ff).stats.max(ind(ss));
  val2                  = dfld(ff).stats.min(ind(ss));
  value(3*(ss-1)+1)     = val1;
  value(3*(ss-1)+2)     = val2;
  value(3*(ss-1)+3)     = max(abs([val1 val2]));
  end
  fprintf(1,'\n')
  fprintf(1, '%12.3f\t',value)
  
  valueM(ff,:)          = value;
 end

fprintf(1,'\n')

valueM_sorted           = sort(valueM(:,3:3:end));

if length(dfld)>=5
fprintf('Fifth highest value\n')
fprintf('X\tY\tZ\tK\tM\n')
fprintf(1, '%12.3f\t', valueM_sorted(end-4,:))
fprintf(1,'\n')
end

% maximum horizontal force
indx    = find(strncmpi('F_turret_X',{dfld(1).signals.dlfName},10));
indy    = find(strncmpi('F_turret_Y',{dfld(1).signals.dlfName},10));
F_horizontal    = zeros(length(dfld(1).time),length(dfld))+NaN;
 for ff = 1:length(dfld)
  F_horizontal(:,ff)    = (dfld(ff).data(:,indx).^2 + dfld(ff).data(:,indy).^2).^(1/2);
 end

valueM          = zeros(length(dfld), 1*3) + NaN;
value           = [];
for ff = 1:length(dfld)
  val1                  = max(F_horizontal(:,ff));
  val2                  = min(F_horizontal(:,ff));
  value(1)      = val1;
  value(2)      = val2;
  value(3)      = max(abs([val1 val2]));

  fprintf(1,'\n')
  fprintf(1, '%12.3f\t',value)
  
  valueM(ff,:)          = value;
 end

fprintf(1,'\n')
valueM_sorted           = sort(valueM(:,3));

if length(dfld)>=5
fprintf('Fifth highest value\n')
fprintf('Horizontal Force (kN)\n')
fprintf(1, '%12.3f\t', valueM_sorted(end-4,:))
fprintf(1,'\n')
end


% motion statistics

table   = {
'X_mot (m)'                     'X_mot'
'Y_mot (m)'                     'Y_mot'
'Z_mot (m)'                     'Z_mot'
'Turret Offset X (m)'           'X_ref1'
'Turret Offset Y (m)'           'Y_ref1'
'Turret Offset Z (m)'           'Z_ref1'
'Total Offset CoG (m)'          'Offset'
'Total Offset Ref1 (m)'         'Offset_Ref1'
};

value   = [];
valueM  = zeros(length(table), 4) + NaN;
fprintf(1,'\n')
fprintf(1, '\tMean\tStd\tMin\tMax')
for tt=1:length(table)
fprintf(1, '\n%s\n', table{tt,1});
ind             = find(strcmpi(table{tt,2},{dfld(1).signals.dlfName}));
for ff = 1:length(dfld)
  value(1)      = dfld(ff).stats.mean(ind);
  value(2)      = dfld(ff).stats.std(ind);
  value(3)      = dfld(ff).stats.min(ind);
  value(4)      = dfld(ff).stats.max(ind);
  fprintf(1, '\t%8.3f  \t%8.3f \t%8.3f \t%8.3f\n',value)
  valueM(ff,:)  = value;
end

if length(dfld)>=5
valueM_sorted           = sort(valueM);
fprintf('Fifth highest value\n')
fprintf('Mean\tStd\tMin\tMax\n')
fprintf(1, '%12.3f\t', [valueM_sorted(end-4,1:2) valueM_sorted(3,3) valueM_sorted(end-4,4)])
fprintf(1,'\n')
end

end

return

