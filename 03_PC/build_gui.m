function build_gui()
root=fileparts(mfilename('fullpath'));addpath(root);dest=fullfile(root,'build');if ~exist(dest,'dir'),mkdir(dest);end
mcc('-e',fullfile(root,'DASDashboard.m'),'-o','DASDashboard','-d',dest,'-I',root);
end
