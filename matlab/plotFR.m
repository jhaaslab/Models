function plotFR
% PLOTFR Interactive plotter for FR/Raster data from simulations
if ~isfolder('data')
    error(['data not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to data folder.'])
end

load([pwd '/vars/sim_vars.mat'],'namesOfNeurons','tspan','var_names','var_combos','perBlk','reps');

SpikeData = load([pwd '/data/SpikeData1.mat']);
SpikeData = SpikeData.SpikeData;

FRData = load([pwd '/data/FRData1.mat']);
FRData = FRData.FRData;

% julia data needs to be restructured to be consistent with matlab
% this may slow down startup only for the first time after a new simulation
if iscell(SpikeData)
    numBlks = ceil(length(var_combos)/perBlk);
    for b = numBlks:-1:1
        SpikeData = load([pwd '/data/SpikeData' num2str(b) '.mat']);
        SpikeData = SpikeData.SpikeData;

        SpikeData=[SpikeData{:}];
        save([pwd '/data/SpikeData' num2str(b) '.mat'],'SpikeData');
    end
end

if iscell(FRData)
    numBlks = ceil(length(var_combos)/perBlk);
    for b = numBlks:-1:1
        FRData = load([pwd '/data/FRData' num2str(b) '.mat']);
        FRData = FRData.FRData;

        FRData=[FRData{:}];
        save([pwd '/data/FRData' num2str(b) '.mat'],'FRData');
    end
end


fig = uifigure;
fig.Name = "Plot FR Data";
fig.Position = [100 100 1000 500];

% Main grid
grid1 = uigridlayout(fig,[1 2]);
grid1.ColumnWidth = {'fit','1x'};


% UIgrid
if any(contains(var_names, 'rep'))
    var_names = var_names(2:end);
    var_combos= unique(var_combos(:,2:end),'rows');
end
numVars = length(var_names);
numRows = 2+numVars;
rowFits={repmat({'fit'},1,numRows)};

UIgrid = uigridlayout(grid1,[numRows, 4]);
UIgrid.RowHeight = rowFits{:};

% UI contols
% save plots
saveBtn = uibutton(UIgrid);
saveBtn.Text = 'Save Plots';
saveBtn.ButtonPushedFcn = @saveData;

% tspan
dt=FRData(1).dt;
t = dt/2:dt:tspan(2);
tspanLbl = uilabel(UIgrid);
tspanLbl.Text = 'Timespan';
tspanLbl.HorizontalAlignment = 'right';

t1 = uispinner(UIgrid);
t1.Value = tspan(1);
t1.ValueDisplayFormat = '%.0f ms';
t1.Limits = tspan;
t1.UpperLimitInclusive = 'off';
t1.ValueChangedFcn = @updatePlots;

t2 = uispinner(UIgrid);
t2.Value = tspan(2);
t2.ValueDisplayFormat = '%.0f ms';
t2.Limits = tspan;
t2.LowerLimitInclusive = 'off';
t2.ValueChangedFcn = @updatePlots;


% mean FR
meanLbl = uilabel(UIgrid);
meanLbl.Text = 'display Mean FR:';
meanLbl.HorizontalAlignment = 'right';

meancbx = uicheckbox(UIgrid);
meancbx.ValueChangedFcn = @updatePlots;

meant1 = uispinner(UIgrid);
meant1.Value = tspan(1);
meant1.ValueDisplayFormat = '%.0f ms';
meant1.Limits = tspan;
meant1.UpperLimitInclusive = 'off';
meant1.ValueChangedFcn = @updatePlots;

meant2 = uispinner(UIgrid);
meant2.Value = tspan(2);
meant2.ValueDisplayFormat = '%.0f ms';
meant2.Limits = tspan;
meant2.LowerLimitInclusive = 'off';
meant2.ValueChangedFcn = @updatePlots;


% Var sliders
for i = 1:numVars
    var_vectors(i) = {unique(var_combos(:,i))}; %#ok<*AGROW>

    varLbl(i) = uilabel(UIgrid);
    varLbl(i).Text = var_names{i};
    varLbl(i).HorizontalAlignment = 'right';

    lb(i) = uibutton(UIgrid);
    lb(i).Text = '<-';

    varDisp(i) = uieditfield(UIgrid,'numeric');
    varDisp(i).Value = var_vectors{i}(1);
    varDisp(i).UserData = struct('vars',var_vectors(i),'currIdx',1);
    varDisp(i).Editable = 'off';

    rb(i) = uibutton(UIgrid);
    rb(i).Text = '->';

    lb(i).ButtonPushedFcn = {@sliderMoved, varDisp(i)};
    rb(i).ButtonPushedFcn = {@sliderMoved, varDisp(i)};
end


% Raster/FR tab
plotTabs = uitabgroup(grid1);
plotTabs.SelectionChangedFcn = @switchTab;
plotTabs.UserData.currSimIdx = 1;

numNeurons = length(namesOfNeurons);
[nRows, nCols] = fitPlots(numNeurons);

% FR
FRtab  = uitab(plotTabs,'Title','Firing Rate');
FRgrid = uigridlayout(FRtab,[nRows, nCols]);

for i = 1:numNeurons
    axFR(i) = uiaxes(FRgrid);
    axFR(i).Title.String = namesOfNeurons{i};
end

% Rasters
RasterTab  = uitab(plotTabs,'Title','Rasters');
RasterGrid = uigridlayout(RasterTab,[nRows nCols]);

for i = 1:numNeurons
    axRasters(i) = uiaxes(RasterGrid);
    axRasters(i).Title.String = namesOfNeurons{i};
end


updatePlots;


% Callbacks
function switchTab(~,event)
    tab = event.NewValue.Title;

    switch tab
    case 'Firing Rate'
        meanLbl.Visible = 'on';
        meancbx.Visible = 'on';
        meant1.Visible  = 'on';
        meant2.Visible  = 'on';
    case 'Rasters'
        meanLbl.Visible = 'off';
        meancbx.Visible = 'off';
        meant1.Visible  = 'off';
        meant2.Visible  = 'off';
    end

end

function sliderMoved(src,~,varDisp)
    idx = varDisp.UserData.currIdx;
    maxIdx = length(varDisp.UserData.vars);

    vars = varDisp.UserData.vars;

    btn = src.Text;
    switch btn
    case '->'
        if idx < maxIdx
        varDisp.Value = vars(idx+1);

        varDisp.UserData.currIdx = idx+1;

        updatePlots;
        end
    case '<-'
        if idx > 1
        varDisp.Value = vars(idx-1);

        varDisp.UserData.currIdx = idx-1;

        updatePlots;
        end
    end
end

function updatePlots(~,~)
    %tic
    simIdx = find(ismember(var_combos,[varDisp(:).Value],'rows'));

    if simIdx ~= plotTabs.UserData.currSimIdx
        if ceil(simIdx/perBlk) ~= ceil(plotTabs.UserData.currSimIdx/perBlk)
            SpikeData = load([pwd '/data/SpikeData' num2str(ceil(simIdx/perBlk)) '.mat']);
            SpikeData = SpikeData.SpikeData;
            
            FRData = load([pwd '/data/FRData' num2str(ceil(simIdx/perBlk)) '.mat']);
            FRData = FRData.FRData;
        end

        plotTabs.UserData.currSimIdx = simIdx;
    end

    for ii=1:numNeurons
        FR = FRData(1+mod(simIdx-1,perBlk)).FR.(namesOfNeurons{ii});
        meanFR = mean(FR(t>meant1.Value & t<meant2.Value));

        hold(axFR(ii),'off')
        plot(axFR(ii),t,FR);
        xlim(axFR(ii),[t1.Value, t2.Value]);
        ylim(axFR(ii),[0, 50]);

        if meancbx.Value == 1
            hold(axFR(ii),'on')
            plot(axFR(ii),[meant1.Value meant2.Value],[meanFR meanFR]);

            txt = ['Mean FR: ' num2str(meanFR) ' Hz'];
            text(axFR(ii),(tspan(1)+tspan(2))/2,40,txt);
        end

        spks=[];

        % if reps is high plot a subset
        trials=reps;
        if reps>40
            trials = 40;
        end

        for trial = 1:trials
            tspks = SpikeData(1+mod(simIdx-1,perBlk)).spiketimes.(namesOfNeurons{ii}){trial};
            spks = [spks, [tspks';repmat(trial,1,length(tspks))]];
        end

        plot(axRasters(ii),spks(1,:),spks(2,:)-0.5,'k.','MarkerSize',8);
        xlim(axRasters(ii),[t1.Value, t2.Value]);
    end
    %toc
end

function saveData(~,~)
    tab = plotTabs.SelectedTab.Title;
    switch tab
    case 'Firing Rate'
        ax = FRgrid;
    case 'Rasters'
        ax = RasterGrid;
    end

    filter = {'*.pdf';'*.jpg';'*.png';'*.tif';'*.eps'};
    [filename,filepath] = uiputfile(filter);
    if ischar(filename)
        exportgraphics(ax,[filepath filename]);
    end
end


% Helper functions
function [nRows, nCols] = fitPlots(numCells)
    if numCells >= 7
        nCols = 3;
        nRows = ceil(numCells/3);
    elseif numCells >= 4
        nCols = 2;
        nRows = ceil(numCells/2);
    else % 1-3 cells
        nCols = 1;
        nRows = numCells;
    end
end


end %main
