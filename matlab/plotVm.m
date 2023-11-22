function plotVm
% PLOTFR Interactive plotter for FR/Raster data from simulations
if ~isfolder('results')
    error(['results not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to results folder.'])
end

load([pwd '/results/sim_vars.mat'], 'namesOfNeurons','tspan','dt','var_names','var_combos');
load([pwd '/results/Sim_results1.mat'], 'Sim_results');


fig = uifigure;
fig.Name = "Plot Vm Data";
fig.Position = [100 100 1000 500];

% Main grid
grid1 = uigridlayout(fig,[2 1]);
grid1.RowHeight = {'1x','fit'};


n = length(namesOfNeurons);
[nRows, nCols] = fitPlots(n);

% Vm plots
plotGrid = uigridlayout(grid1,[nRows, nCols]);
plotGrid.UserData.currSimIdx = 1;

for i = 1:n
    ax(i) = uiaxes(plotGrid);
    ax(i).Title.String = namesOfNeurons{i};
end


% UIgrid
UIgrid = uigridlayout(grid1,[2, 8]);
UIgrid.RowHeight = {'fit','fit'};

% UI contols
% save plots
saveBtn = uibutton(UIgrid);
saveBtn.Text = 'Save Plots';
saveBtn.ButtonPushedFcn = @saveData;

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

% replication slider
reps = 1:50;

repLbl = uilabel(UIgrid);
repLbl.Text = 'replication';
repLbl.HorizontalAlignment = 'right';

lbRep = uibutton(UIgrid);
lbRep.Text = '<-';

varDispRep = uieditfield(UIgrid,'numeric');
varDispRep.Value = reps(1);
varDispRep.UserData = struct('vars',reps,'currIdx',i);
varDispRep.Editable = 'off';

rbRep = uibutton(UIgrid);
rbRep.Text = '->';

lbRep.ButtonPushedFcn = {@sliderMoved, varDispRep};
rbRep.ButtonPushedFcn = {@sliderMoved, varDispRep};


% Var sliders
numVarRows = ceil(length(var_names)/2);
rowFits={repmat({'fit'},1,numVarRows)};

varGrid = uigridlayout(UIgrid,[numVarRows, 8]);
varGrid.RowHeight = rowFits{:};
varGrid.Layout.Column = [1,8];

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

    if simIdx ~= plotGrid.UserData.currSimIdx
    load([pwd '/results/Sim_results' num2str(simIdx) '.mat'], 'Sim_results');
    plotGrid.UserData.currSimIdx = simIdx;
    end

    t = tspan(1):dt:tspan(2);
    tIdx = find(t>=t1.Value & t<=t2.Value);

    for ii=1:n
        vm = Sim_results(varDispRep.Value).data.(namesOfNeurons{ii});
        plot(ax(ii),t(tIdx),vm(tIdx));
    end
    %toc
end

function saveData(~,~)
    filter = {'*.jpg';'*.png';'*.tif';'*.pdf';'*.eps'};
    [filename,filepath] = uiputfile(filter);
    if ischar(filename)
        exportgraphics(plotGrid,[filepath filename]);
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
