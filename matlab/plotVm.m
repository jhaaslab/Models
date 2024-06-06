function plotVm
% PLOTVM Interactive plotter for FR/Raster data from simulations
if ~isfolder('results')
    error(['results not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to results folder.'])
end

load([pwd '/vars/sim_vars.mat'], 'namesOfNeurons','tspan','var_names','var_combos','perBlock');

load([pwd '/results/simResults1.mat'], 'simResults');


fig = uifigure;
fig.Name = "Plot Vm Data";
fig.Position = [100 100 1000 500];

% Main grid
grid1 = uigridlayout(fig,[1 2]);
grid1.ColumnWidth = {'fit','1x'};


% UIgrid
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


% Var sliders
for i = 1:numVars
    var_vectors(i) = {unique(var_combos(:,i))};

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


% Vm plots
numNeurons = length(namesOfNeurons);
[nRows, nCols] = fitPlots(numNeurons);

plotGrid = uigridlayout(grid1,[nRows, nCols]);
plotGrid.UserData.currSimIdx = 1;

for n = 1:numNeurons
    ax(n) = uiaxes(plotGrid);
    ax(n).Title.String = namesOfNeurons{n};
end


updatePlots;
uiwait(fig)

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
        if ceil(simIdx/perBlock) ~= ceil(plotGrid.UserData.currSimIdx/perBlock)
            load([pwd '/results/simResults' num2str(ceil(simIdx/perBlock)) '.mat'], 'simResults');
        end

        plotGrid.UserData.currSimIdx = simIdx;
    end

    t = simResults(1+mod(simIdx-1,perBlock)).data.time;
    for ii=1:numNeurons
        vm = simResults(1+mod(simIdx-1,perBlock)).data.(namesOfNeurons{ii});
        plot(ax(ii),t,vm);
        xlim(ax(ii),[t1.Value, t2.Value]);
        ylim(ax(ii),[-100, 50]);
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
