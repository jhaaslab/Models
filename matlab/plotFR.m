function plotFR
% PLOTFR Interactive plotter for FR/Raster data from simulations
if ~isfolder('data')
    error(['data not found in current working directory. '...
     'cd to sim directory and ensure sim data was extracted.'])
end

load([pwd '/results/sim_vars.mat'], 'namesOfNeurons','tspan','var_names','var_combos');
load([pwd '/data/spk_data.mat'],    'spk_data');


fig = uifigure;
fig.Name = "Plot FR Data";
fig.Position = [100 100 1000 500];

% Main grid
grid1 = uigridlayout(fig,[2 1]);
grid1.RowHeight = {'1x','fit'};


% Raster/FR tab
plotTabs = uitabgroup(grid1);
plotTabs.SelectionChangedFcn = @switchTab;

n = length(namesOfNeurons);
[nRows, nCols] = fitPlots(n);

% FR
FRtab = uitab(plotTabs,'Title','Firing Rate');
FRgrid = uigridlayout(FRtab,[nRows, nCols]);

for i = 1:n
    axFR(i) = uiaxes(FRgrid);
    axFR(i).Title.String = namesOfNeurons{i};
end

% Rasters
RasterTab = uitab(plotTabs,'Title','Rasters');
RasterGrid = uigridlayout(RasterTab,[nRows nCols]);

for i = 1:n
    axRasters(i) = uiaxes(RasterGrid);
    axRasters(i).Title.String = namesOfNeurons{i};
end


% UIgrid
UIgrid = uigridlayout(grid1,[2, 6]);
UIgrid.RowHeight = {'fit','fit'};

% UI contols
% save plots
saveBtn = uibutton(UIgrid);
saveBtn.Text = 'Save Plots';
saveBtn.ButtonPushedFcn = @saveData;

% normalize
normLbl = uilabel(UIgrid);
normLbl.Text = 'Normalize:';
normLbl.HorizontalAlignment = 'right';

normField = uieditfield(UIgrid, 'numeric');
normField.Value = 1;
normField.ValueChangedFcn = @updatePlots;

% tspan
tspanLbl = uilabel(UIgrid);
tspanLbl.Text = 'Timespan';
tspanLbl.HorizontalAlignment = 'right';

t1 = uieditfield(UIgrid,'numeric');
t1.Value = tspan(1);
t1.ValueDisplayFormat = '%.0f ms';
t1.Limits = tspan;
t1.UpperLimitInclusive = 'off';
t1.ValueChangedFcn = @updatePlots;

t2 = uieditfield(UIgrid,'numeric');
t2.Value = tspan(2);
t2.ValueDisplayFormat = '%.0f ms';
t2.Limits = tspan;
t2.LowerLimitInclusive = 'off';
t2.ValueChangedFcn = @updatePlots;

% Var sliders
numVarRows = ceil(length(var_names)/2);
rowFits={repmat({'fit'},1,numVarRows)};

varGrid = uigridlayout(UIgrid,[numVarRows, 8]);
varGrid.RowHeight = rowFits{:};
varGrid.Layout.Column = [1,6];

for i = 1:length(var_names)
    var_vectors(i) = {unique(var_combos(:,i))};

    varLbl(i) = uilabel(varGrid);
    varLbl(i).Text = var_names{i};
    varLbl(i).HorizontalAlignment = 'right';

    lb(i) = uibutton(varGrid);
    lb(i).Text = '<-';

    varDisp(i) = uieditfield(varGrid,'numeric');
    varDisp(i).Value = var_vectors{i}(1);
    varDisp(i).UserData = struct('vars',var_vectors(i),'currIdx',i);
    varDisp(i).Editable = 'off'; 

    rb(i) = uibutton(varGrid);
    rb(i).Text = '->';

    lb(i).ButtonPushedFcn = {@sliderMoved, varDisp(i)};
    rb(i).ButtonPushedFcn = {@sliderMoved, varDisp(i)};
end

updatePlots;

% Callbacks 
function switchTab(~,event)
    tab = event.NewValue.Title;
    switch tab
    case 'Firing Rate'
        normLbl.Visible = 'on';
        normField.Visible = 'on';
    case 'Rasters'
        normLbl.Visible = 'off';
        normField.Visible = 'off';
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
    idx = find(ismember(var_combos,[varDisp(:).Value],'rows'));

    t = spk_data(idx).FR.time;
    tIdx = find(t>=t1.Value & t<=t2.Value);

    for ii=1:n
        FR = spk_data(idx).FR.(namesOfNeurons{ii})./normField.Value;
        plot(axFR(ii),t(tIdx),FR(tIdx));

        spks=[];
        for trial = 1:40
        tspks = spk_data(idx).spktime.(namesOfNeurons{ii}){trial};
        spks = [spks, [tspks;repmat(trial,1,length(tspks))]];
        end

        plot(axRasters(ii),spks(1,:),spks(2,:)-0.5,'k.','MarkerSize',8);
        axRasters(ii).XLim = [t1.Value t2.Value];
    end
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
