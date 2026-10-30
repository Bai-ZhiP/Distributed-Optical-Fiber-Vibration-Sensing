function ok=rbs_write_json(path,value)
% Commit a complete document; readers never observe a half-written JSON file.
ok=false;temp=[path '.tmp'];f=fopen(temp,'w');if f<0,return;end
fprintf(f,'%s',jsonencode(value));fclose(f);[ok,~]=movefile(temp,path,'f');
end
