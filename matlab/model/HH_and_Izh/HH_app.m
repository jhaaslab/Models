clear all

global data


HHapp = uifigure('Name', 'Hodgkin-Huxley Model',...
    'Position',[100 100 1000 500]);

%% Plots
% Neuron 1
ax1 = uiaxes(HHapp,'Position',[500 300 500 200]);
ax1.Title.String = 'Neuron';
ax1.XLabel.String = 'time (ms)';
ax1.YLabel.String = 'Voltage (mV)';

% I applied
ax2 = uiaxes(HHapp,'Position',[500 100 500 150]);
ax2.Title.String = 'I applied';
ax2.YLim = [-35 35];
ax2.XLabel.String = 'time (ms)';
ax2.YLabel.String = 'Current (uA/cm^2)';

%% G channel controls
% Na
gNa_lbl = uilabel(HHapp, 'Position',[30 475 100 20]);
gNa_lbl.Text = 'gbar Na';

gbar_Na_num = uieditfield(HHapp,'numeric',...
    'Position',[30 450 100 22]);
gbar_Na_num.Limits = [0 240];
gbar_Na_num.Value = 120;

gbar_Na_kb = uiknob(HHapp,...
    'Position',[50 350 60 60],...
    'ValueChangingFcn',@(gbar_Na_kb,event) knobTurned(gbar_Na_kb,event,gbar_Na_num));
gbar_Na_kb.Limits = [0 240];
gbar_Na_kb.Value = 120;

% K
gK_lbl = uilabel(HHapp, 'Position',[180 475 100 20]);
gK_lbl.Text = 'gbar K';

gbar_K_num = uieditfield(HHapp,'numeric',...
    'Position',[180 450 100 22]);
gbar_K_num.Limits = [0 72];
gbar_K_num.Value = 36;

gbar_K_kb = uiknob(HHapp,...
    'Position',[200 350 60 60],...
    'ValueChangingFcn',@(gbar_K_kb,event) knobTurned(gbar_K_kb,event,gbar_K_num));
gbar_K_kb.Limits = [0 72];
gbar_K_kb.Value = 36;

% Leak
gL_lbl = uilabel(HHapp, 'Position',[330 475 100 20]);
gL_lbl.Text = 'gbar Leak';

gbar_L_num = uieditfield(HHapp,'numeric',...
    'Position',[330 450 100 22]);
gbar_L_num.Limits = [0 0.6];
gbar_L_num.Value = 0.3;

gbar_L_kb = uiknob(HHapp,...
    'Position',[350 350 60 60],...
    'ValueChangingFcn',@(gbar_L_kb,event) knobTurned(gbar_L_kb,event,gbar_L_num));
gbar_L_kb.Limits = [0 0.6];
gbar_L_kb.Value = 0.3;

%% I applied controls
stim_tabgrp = uitabgroup(HHapp,'Position',[10 10 450 290]);
DC_tab = uitab(stim_tabgrp,'Title','DC input');
sine_tab = uitab(stim_tabgrp,'Title','Sine input');

% DC input
Iapp_lbl = uilabel(DC_tab, 'Position',[300 170 100 20]);
Iapp_lbl.Text = 'I applied';

Iapp_num = uieditfield(DC_tab,'numeric',...
    'Position',[300 145 100 22]);
Iapp_num.Limits = [-30 30];
Iapp_num.Value = 0;

Iapp_kb = uiknob(DC_tab,...
    'Position',[110 105 100 100],...
    'ValueChangingFcn',@(Iapp_kb,event) knobTurned(Iapp_kb,event,Iapp_num));
Iapp_kb.Limits = [-30 30];
Iapp_kb.Value = 0;

t_stim_lbl = uilabel(DC_tab, 'Position',[300 75 100 20]);
t_stim_lbl.Text = 'stimulus length';

t_stim_num = uieditfield(DC_tab,'numeric',...
    'Position',[300 50 100 22]);
t_stim_num.Limits = [0 400];
t_stim_num.Value = 0;

t_stim_sld = uislider(DC_tab,...
    'Position',[50 50 220 3],...
    'ValueChangingFcn',@(t_stim_sld,event) sliderMoving(event,t_stim_num));
t_stim_sld.Limits = [0 400];
t_stim_sld.Value = 0;

% Sine wave input
amp_lbl = uilabel(sine_tab, 'Position',[60 210 100 20]);
amp_lbl.Text = 'amplitude';

amp_num = uieditfield(sine_tab,'numeric',...
    'Position',[60 185 100 22]);
amp_num.Limits = [0 30];
amp_num.Value = 0;

amp_kb = uiknob(sine_tab,...
    'Position',[60 50 100 100],...
    'ValueChangingFcn',@(amp_kb,event) knobTurned(amp_kb,event,amp_num));
amp_kb.Limits = [0 30];
amp_kb.Value = 0;

freq_lbl = uilabel(sine_tab, 'Position',[260 210 100 20]);
freq_lbl.Text = 'frequency';

freq_num = uieditfield(sine_tab,'numeric',...
    'Position',[260 185 100 22]);
freq_num.Limits = [1 30];
freq_num.Value = 1;

freq_kb = uiknob(sine_tab,...
    'Position',[260 50 100 100],...
    'ValueChangingFcn',@(freq_kb,event) knobTurned(freq_kb,event,freq_num));
freq_kb.Limits = [1 30];
freq_kb.Value = 1;

%% Run/Save buttons
run_btn = uibutton(HHapp,'Text', 'Run',...
    'Position',[600 50 100 22],...
    'ButtonPushedFcn', @(run_btn,event) runModel(run_btn,ax1,ax2,gbar_Na_num,gbar_K_num,gbar_L_num,stim_tabgrp,Iapp_num,t_stim_num,amp_num,freq_num));

save_btn = uibutton(HHapp, 'Text', 'Save',...
    'Position',[800 50 100 22],...
    'ButtonPushedFcn', @(save_btn,event) saveButtonPushed(save_btn,HHapp));

%% Callback functions
function runModel(event,ax1,ax2,gbar_Na_num,gbar_K_num,gbar_L_num,stim_tabgrp,Iapp_num,t_stim_num,amp_num,freq_num)
    global stim Iapp t_stim amp freq gbar_Na gbar_K gbar_L data
    
    stim = stim_tabgrp.SelectedTab.Title;
    
    if strcmp(stim,'DC input') == 1
        Iapp = Iapp_num.Value;
        t_stim = t_stim_num.Value;
    else %sine input
        amp = amp_num.Value;
        freq = freq_num.Value;
    end
    
    gbar_Na = gbar_Na_num.Value;
    gbar_K = gbar_K_num.Value;
    gbar_L = gbar_L_num.Value;
    
    ICs = [-69.8977, .0536, 0.5925, .3192];
    options=odeset('RelTol',1e-8);
    [t,S]=ode23(@dHHapp,[0 500],ICs,options);
    
    v=S(:,1);
    
    if strcmp(stim,'DC input') == 1
        y=zeros(1,length(t));
        y(t>50&t<50+t_stim) = Iapp;
    else
        y = amp*sin(2*pi*freq*(t/1000));
    end
    
    plot(ax1, t, v)
    plot(ax2, t, y)
    
    data = [t, v];
end

function sliderMoving(event,num)
    num.Value = event.Value;
end

function knobTurned(kb,event,num)
    num.Value = event.Value;
end

function saveButtonPushed(btn,HHapp)
    global data
    uisave('data');
    figure(HHapp);
end