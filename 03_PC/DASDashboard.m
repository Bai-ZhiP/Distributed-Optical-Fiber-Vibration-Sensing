function DASDashboard(dataDir,durationSeconds,mode)
% Compiled application entry. The launcher starts the network receiver first.
if nargin<1 || isempty(dataDir),error('DAS:DataPath','A receiver directory is required.');end
if nargin<2,durationSeconds=Inf;elseif ischar(durationSeconds),durationSeconds=str2double(durationSeconds);end
if nargin<3,mode='viewer';end
try
 if strcmp(mode,'processor')
  diary(fullfile(dataDir,'processor.log'));rbs_iq_processor(durationSeconds,dataDir);diary off;return;
 end
 diary(fullfile(dataDir,'dashboard.log'));
 st=jsondecode(fileread(fullfile(dataDir,'status.json')));
 if isfield(st,'format')&&strcmp(st.format,'IQ16')
  rbs_fast_iq_live(durationSeconds,dataDir);
 else
  matlab_rbs_live(durationSeconds,dataDir);
 end
catch err
 fprintf(2,'%s\n',getReport(err,'extended','hyperlinks','off'));
 if strcmp(mode,'processor'),diary off;rethrow(err);end
 uiwait(errordlg(sprintf('DAS stopped: %s\n\nSee dashboard.log in:\n%s',err.message,dataDir),'DAS Monitor'));
end
diary off;
end
