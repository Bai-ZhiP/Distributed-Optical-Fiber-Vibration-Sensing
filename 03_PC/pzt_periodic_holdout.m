function [correlation,predictableRms,coverage,fold]=pzt_periodic_holdout(phase,t,frequencyHz)
% First-half periodic model evaluated on independent second-half samples.
% Unit phasors avoid assuming phase can be unwrapped at the raw trace rate.
t=t(:);p=double(phase);ok=isfinite(p);q=exp(1i*p);q(~ok)=0;
n=numel(t);nb=50;bin=mod(round(mod(t*frequencyHz,1)*nb),nb)+1;
train=(1:n)'<=floor(n/2);test=~train;
selector=sparse(bin(train),find(train),1,nb,n);
counts=selector*double(ok);fold=(selector*q)./max(counts,1);
use=ok(test,:) & counts(bin(test),:)>=4;
a=q(test,:);b=fold(bin(test),:);a(~use)=0;b(~use)=0;
den=max(sum(use,1),1);a=(a-sum(a,1)./den).*use;b=(b-sum(b,1)./den).*use;
ea=sum(abs(a).^2,1);eb=sum(abs(b).^2,1);
correlation=abs(sum(a.*conj(b),1))./sqrt(max(eps,ea.*eb));
coverage=sum(use,1)/sum(test);correlation(coverage<.8)=NaN;
predictableRms=correlation.*sqrt(ea./den);
end
