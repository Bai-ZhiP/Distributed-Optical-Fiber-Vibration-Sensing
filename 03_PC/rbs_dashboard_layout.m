function ui = rbs_dashboard_layout()
% One desktop page for the live maps and the measured PZT waveforms.
bg=[.96 .97 .985]; ink=[.10 .16 .25];
ui.fig=figure('Name','DAS Monitor | Live space-time, waveform and spectrum',...
 'NumberTitle','off','Color',bg,'Position',[30 40 1540 880],...
 'MenuBar','none','ToolBar','figure');
try,set(ui.fig,'WindowState','maximized');catch,end
ui.heading=annotation(ui.fig,'textbox',[.025 .943 .7 .04],'EdgeColor','none',...
 'String','DAS  |  20 km junction monitoring','FontSize',19,'FontWeight','bold',...
 'HorizontalAlignment','left','BackgroundColor',bg,'Color',ink);
ui.status=annotation(ui.fig,'textbox',[.025 .908 .95 .03],'EdgeColor','none',...
 'String','Connecting to live FPGA data...','FontSize',10,...
 'HorizontalAlignment','left','BackgroundColor',bg,'Color',ink);
annotation(ui.fig,'textbox',[.86 .949 .115 .033],'String','Save snapshot','FontSize',10,...
 'HorizontalAlignment','center','EdgeColor',[.5 .6 .7],'ButtonDownFcn',@(s,e) snapshot(ui.fig));
left=[.055 .712 .48 .14;.055 .407 .48 .225;.055 .098 .48 .225];
right=[.635 .712 .335 .14;.635 .407 .335 .225;.635 .098 .335 .225];
ui.left=gobjects(1,3);ui.right=gobjects(1,3);
for k=1:3
 ui.left(k)=axes('Parent',ui.fig,'Position',left(k,:),'FontSize',10,'Box','on');
 ui.right(k)=axes('Parent',ui.fig,'Position',right(k,:),'FontSize',10,'Box','on');
end
ui.footer=annotation(ui.fig,'textbox',[.025 .016 .95 .035],'EdgeColor','none',...
 'String','Measured data | distance zero not calibrated | weak signal and missing samples are masked | no calibrated strain amplitude',...
 'FontSize',10,'HorizontalAlignment','left','BackgroundColor',bg,'Color',[.35 .4 .48]);
end

function snapshot(fig)
[f,p]=uiputfile('DAS_snapshot.png','Save current dashboard');
if isequal(f,0),return;end
saveas(fig,fullfile(p,f));
end
