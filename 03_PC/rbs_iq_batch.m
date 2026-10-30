function [power,strict,diagnostic,state,z,measured] = rbs_iq_batch(iq,ticks,state)
% Measured 20.42 m differential pairs on the established search-bin grid.
n=size(iq,1);ix=11:1:n-10;left=ix-1;right=ix+1;
z=((ix-1)*25+12)*299792458/(2*1.468*250e6)/1000;
if nargin<3||isempty(state),state=struct('previous',iq(:,1),'lastTick',NaN);end
previous=[state.previous iq(:,1:end-1)];dt=diff([state.lastTick ticks])/250e6;
power=single(real(iq).^2+imag(iq).^2);
if ~isfield(state,'previousPower'),state.previousPower=single(abs(state.previous).^2);end
priorPower=[state.previousPower power(:,1:end-1)];
temporal=iq.*conj(previous);increment=temporal(right,:).*conj(temporal(left,:));
measured=angle(increment);measured(~isfinite(increment)|increment==0)=NaN;
strict=measured;
good=power(left,:)>=36&power(right,:)>=36&priorPower(left,:)>=36&priorPower(right,:)>=36;
strict(~good)=NaN;invalid=~isfinite(dt)|dt<=0|dt>=.0015;strict(:,invalid)=NaN;
strict=single(strict);diagnostic=strict;
measured(:,invalid)=NaN;measured=single(measured);
state=struct('previous',iq(:,end),'previousPower',power(:,end),'lastTick',ticks(end));
end
