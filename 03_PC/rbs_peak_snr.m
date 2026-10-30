function snr = rbs_peak_snr(power,f,peakIndex)
% The exact same local band/median score, evaluated only at requested peaks.
% This avoids computing hundreds of unused moving medians per location.
nr=size(power,1);nc=size(power,2);peakIndex=reshape(peakIndex,1,[]);
radius=max(1,ceil(1/(f(2)-f(1))));noiseWidth=max(8,round(15/(f(2)-f(1))));
row=(-noiseWidth:noiseWidth)'+peakIndex;ok=row>=1&row<=nr;
index=max(1,min(nr,row))+(0:nc-1)*nr;
values=power(index);values(~ok)=NaN;
noise=median(values,1,'omitnan')/log(2)*(2*radius+1);
row=(-radius:radius)'+peakIndex;ok=row>=1&row<=nr;index=max(1,min(nr,row))+(0:nc-1)*nr;
values=power(index);values(~ok)=0;bandPower=sum(values,1);
snr=10*log10(max(bandPower-noise,realmin)./max(noise,realmin));
end
