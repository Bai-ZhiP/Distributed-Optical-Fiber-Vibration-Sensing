function [y,info] = rbs_fuse_increments(x,z,centerKm,minimumContributors)
% Select the actual local differential pair; keep tracker interface compatible.
[~,ix]=min(abs(z-centerKm));y=double(x(:,ix));
info=struct('centerKm',z(ix),'indices',ix,'rangeKm',[z(ix) z(ix)],...
 'validFraction',mean(isfinite(y)),'minimumAgreement',NaN,'minimumContributors',1,...
 'coherence',nan(size(y)));
end
