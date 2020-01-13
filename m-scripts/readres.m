function varargout = readres(flNm, varargin)
% $HvZ January 2008
% [DYNFLOATDATA, TSO] = READRES returns dynfloatdata structure and a tso, which can used in the MTB toolbox for a user-selected file (extension *.res)
% [DYNFLOATDATA, TSO] = READRES(FILENAME) same as above, for a pre-specified file (e.g. c:\programs\dfl20031\results\case1.res)
% DYNFLOATDATA = READRES(..., '-notso') returns only the dynfloatdata structure
%
%

if nargin
  if strcmpi(flNm, '-test')
    flNm        = 'C:\Programs\dfl20031\Results\MID.RES';  
  end
end

optionsIndL             = strncmp('-',varargin,1);
options                 = varargin(optionsIndL);
varargin(optionsIndL)   = [];

notso                   = any(strcmpi('-notso', options));


if ~nargin
  % make user select a directory
  [fl,pd] = uigetfilep('*.RES*','Open Dynfloat response file *.res','MultiSelect', 'on');
  
  if ~any(fl)
    % when uigetfile is cancelled it returns 0
    return
  end
  flNm  = [pd fl];
end

signalCntMax    = 324/4; % record length 324
byteorder       = 'ieee-le'; % little endian format for intel processors
fid             = fopen(flNm, 'r', byteorder);
if fid < 0
  error('.')
  return
end

% first record
[ns, cnt]       = fread(fid, 1, 'int32');
[ci1, cnt]      = fread(fid, 1, 'float32'); 

% second record
recInd          = 2;
fseek(fid, gotorecord(2), 'bof')
[lineCnt, cnt]  = fread(fid, 1, 'int32');
[refPtCnt, cnt] = fread(fid, 1, 'int32');

signalCnt       = 37 + lineCnt + 3 * refPtCnt;
rdata           = zeros(ns, signalCnt) + NaN;

% read remaining record starting from 3rd record
for nn = 1:ns
  fseek(fid, gotorecord(2+nn), 'bof');
  [rdata(nn,:), cnt]    = fread(fid, signalCnt, 'float32');
end

%fclose fid
% The above line is replaced with the following:
fclose(fid)

time                    = (0:ci1:(ns-1)*ci1)';


dfld.signals            = dynfloatsignals(lineCnt, refPtCnt);
dfld.data               = rdata;
dfld.time               = time;
dfld.flNm               = flNm;

% CoG offset
indx                    = find(strncmpi('X_mot',{dfld.signals.dlfName},5));
indy                    = find(strncmpi('Y_mot',{dfld.signals.dlfName},5));
offset                  = sqrt(dfld.data(:,indx).^2 + dfld.data(:,indy).^2);

rdata(:,end+1)                  = offset;
dfld.data(:,end+1)              = offset;
dfld.signals(end+1).dlfName     = 'Offset';
dfld.signals(end).dlfLabel      = 'Vessel offset relative to CoG';
dfld.signals(end).units         = 'm';

% reference point 1 offset
indx                    = find(strncmpi('X_ref1',{dfld.signals.dlfName},6));
indy                    = find(strncmpi('Y_ref1',{dfld.signals.dlfName},6));
offset                  = sqrt(dfld.data(:,indx).^2 + dfld.data(:,indy).^2);

rdata(:,end+1)                  = offset;
dfld.data(:,end+1)              = offset;
dfld.signals(end+1).dlfName     = 'Offset_Ref1';
dfld.signals(end).dlfLabel      = 'Vessel offset relative to Reference Pt';
dfld.signals(end).units         = 'm';


stats                   = generatestats(rdata);
dfld.stats              = stats;

varargout{1}            = dfld;
        
% makedlp function commented out.
%if ~notso
% make dlp file?
%[tso, msg]              = makedlp(dfld);
%varargout{2}            = tso;
%end


% ____________________________________________________
%
%
function byteInd = gotorecord(recInd)

recordLength    = 324; % given

byteInd         = recordLength * (recInd-1);

% ____________________________________________________
%
%
function sigTable = dynfloatsignals(lineCnt, refPtCnt)

columnNms       = {
 'dlfName'
 'dlfLabel'
 'units'
};

sigTableC       = {
'Wave'          'Wave elevation'                                                                        'm'  
'X_mot'         'Vessel CoG translation in global X-direction'                                          'm'     
'Y_mot'         'Vessel CoG translation in global Y-direction'                                          'm'     
'Z_mot'         'Vessel CoG translation in global Z-direction'                                          'm'     
'Roll_mot'      'Vessel rotation roll, vessel fixed'                                                    'deg'   
'Pitch_mot'     'Vessel rotation pitch, vessel fixed'                                                   'deg'   
'Yaw_mot'       'Vessel rotation yaw, vessel fixed'                                                     'deg'   
'F_moor_X'      'Mooring load w.r.t CoG, X, vessel fixed'                                               'kN'    
'F_moor_Y'      'Mooring load w.r.t CoG, Y, vessel fixed'                                               'kN'    
'F_moor_Z'      'Mooring load w.r.t CoG, Z, vessel fixed'                                               'kN'    
'F_moor_K'      'Mooring load w.r.t CoG, K, vessel fixed'                                               'kN.m'  
'F_moor_M'      'Mooring load w.r.t CoG, M, vessel fixed'                                               'kN.m'  
'F_moor_N'      'Mooring load w.r.t CoG, N, vessel fixed'                                               'kN.m'  
'F_wind_X'      'Wind load w.r.t CoG, X, vessel fixed'                                                  'kN'    
'F_wind_Y'      'Wind load w.r.t CoG, Y, vessel fixed'                                                  'kN'    
'F_wind_N'      'Wind load w.r.t CoG, N, vessel fixed'                                                  'kN.m'  
'F_lfdamp_X'    'Current and LF damping loads, w.r.t CoG, X, vessel fixed'                              'kN'    
'F_lfdamp_Y'    'Current and LF damping loads, w.r.t CoG, Y, vessel fixed'                              'kN'    
'F_lfdamp_N'    'Current and LF damping loads, w.r.t CoG, N, vessel fixed'                              'kN.m'  
'F_wave_X'      'Wave drift loads, w.r.t CoG, X, vessel fixed'                                          'kN'    
'F_wave_Y'      'Wave drift loads, w.r.t CoG, Y, vessel fixed'                                          'kN'    
'F_wave_Z'      'Wave drift loads, w.r.t CoG, Z, vessel fixed'                                          'kN'    
'F_wave_K'      'Wave drift loads, w.r.t CoG, K, vessel fixed'                                          'kN.m'
'F_wave_M'      'Wave drift loads, w.r.t CoG, M, vessel fixed'                                          'kN.m'
'F_wave_N'      'Wave drift loads, w.r.t CoG, N, vessel fixed'                                          'kN.m'
'F_envir_X'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, X, vessel fixed'          'kN'
'F_envir_Y'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, Y, vessel fixed'          'kN'
'F_envir_Z'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, Z, vessel fixed'          'kN'
'F_envir_K'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, K, vessel fixed'          'kN.m'
'F_envir_M'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, M, vessel fixed'          'kN.m'
'F_envir_N'     'Total environmental loads (wind + lfdamp + wave), w.r.t CoG, N, vessel fixed'          'kN.m'
'F_turret_X'    'Total loads X in turret coordinate system origin, vessel fixed'                        'kN'
'F_turret_Y'    'Total loads Y in turret coordinate system origin, vessel fixed'                        'kN'
'F_turret_Z'    'Total loads Z in turret coordinate system origin, vessel fixed'                        'kN'
'F_turret_K'    'Total loads K in turret coordinate system origin, vessel fixed'                        'kN.m'
'F_turret_M'    'Total loads M in turret coordinate system origin, vessel fixed'                        'kN.m'
'F_turret_N'    'Total loads N in turret coordinate system origin, vessel fixed'                        'kN.m'
'F_mline'       'Mooring line loads (at fairlead), line '                                               'kN'
'X_ref'         'Reference point translation X, global coordinate system, relative to zero position at the design position, point ' 'm'
'Y_ref'         'Reference point translation Y, global coordinate system, relative to zero position at the design position, point ' 'm'
'Z_ref'         'Reference point translation Z, global coordinate system, relative to zero position at the design position, point ' 'm'
};

sigTableC       = replicatepartition(sigTableC, 1, 2, lineCnt, 'line');
sigTableC       = replicatepartition(sigTableC, 1, 2, refPtCnt, 'refpt');

sigTable        = cell2struct(sigTableC, columnNms, 2);


% __________________________________________________________
%
% #replicatepartition
%
%
function tC = replicatepartition(tC0, leadCol, slaveCol, replicateCnt, mode)

% tC: table as cell

% replicate pars for number of lines / reference points

switch mode
  case 'line'
    searchStr   = '_mline';
  case 'refpt'
    searchStr   = '_ref';
  otherwise
    error('.')
end

tC              = {};

for rr = 1:size(tC0, 1)
  % work on nm in first column
  parNmrr       = tC0{rr, leadCol};

  if any(findstri(parNmrr, searchStr))
    % searchStr found, add partitions to all (string) parameters in the row
    for pp = 1:replicateCnt
      % initialise new row
      tC(end+1, :)              = tC0(rr,:);

      for ii = [leadCol slaveCol]
        parNmrr                 = tC{end, ii};
        partNm                  = sprintf('%s%d', parNmrr, pp);
        tC{end, ii}             = partNm;
      end
    end

  else
    tC(end+1,:)                 = tC0(rr,:);

  end

end % for rr = 1:length(tC0)

% #replicatepartition END


% __________________________________________________________
%
% #generatestats
%
%
function st = generatestats(data)

st      = [];

fcnTable        = {
  % fldNm       fcn
  'min'         'min'
  'max'         'max'
  'std'         'std'
  'mean'        'mean'
};

for ff = 1:length(fcnTable)
    stdata      = feval(fcnTable{ff,2}, data);
    st          = setfield(st, fcnTable{ff,2}, stdata);
end % for ff


% #generatestats END

