function plotVm
% PLOTVM Interactive plotter for FR/Raster data from simulations
if ~isfolder('data')
    error(['results not found in current working directory. '...
     'cd to sim directory and ensure sims ran and saved to results folder.'])
end

load([pwd '/vars/sim_vars.mat'],'namesOfNeurons','tspan','dt','var_names','var_combos','perBlk','reps');

% check if sim data came from julia
if any(size(dir('*.jl'),1))
    datapath  = '/results/VmData';
    datafield = 'VmData';    
else
    datapath = '/results/simResults';
    datafield= 'simResults';
end

simResults = load([pwd datapath '1.mat']);
simResults = simResults.(datafield);

% julia data needs to be restructured to be consistent with matlab
% this may slow down startup only for the first time after a new simulation
if iscell(simResults)
    numBlks = ceil(length(var_combos)/perBlk);
    for b = 1:numBlks
        VmData = load([pwd datapath num2str(b) '.mat']);
        VmData = VmData.(datafield);

        VmData=[VmData{:}];
        save([pwd datapath num2str(b) '.mat'],'VmData');
    end
    clear("VmData")

    simResults = load([pwd datapath '1.mat']);
    simResults = simResults.(datafield);
end

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
time = tspan(1):dt:tspan(2);
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

% Rep slider
if reps>1
    rep_vectors = {1:reps};

    repLbl = uilabel(UIgrid);
    repLbl.Text = 'replicate';
    repLbl.HorizontalAlignment = 'right';
    
    rep_lb = uibutton(UIgrid);
    rep_lb.Text = '<-';
    
    repDisp = uieditfield(UIgrid,'numeric');
    repDisp.Value = rep_vectors{1}(1);
    repDisp.UserData = struct('vars',rep_vectors(1),'currIdx',1);
    repDisp.Editable = 'off';
    
    rep_rb = uibutton(UIgrid);
    rep_rb.Text = '->';
    
    rep_lb.ButtonPushedFcn = {@sliderMoved, repDisp};
    rep_rb.ButtonPushedFcn = {@sliderMoved, repDisp};
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
        if ceil(simIdx/perBlk) ~= ceil(plotGrid.UserData.currSimIdx/perBlk)
            simResults = load([pwd datapath num2str(ceil(simIdx/perBlk)) '.mat']);
            simResults = simResults.(datafield);
        end

        plotGrid.UserData.currSimIdx = simIdx;
    end

    for ii=1:numNeurons
        if reps>1
            vm = simResults(repDisp.Value).data.(namesOfNeurons{ii});
        else
            vm = simResults(1+mod(simIdx-1,perBlk)).data.(namesOfNeurons{ii});
        end
        plot(ax(ii),time,vm);
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
