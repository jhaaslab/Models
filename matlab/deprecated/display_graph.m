

load([pwd '/init_data/var_combos.mat'],'var_combos','var_vectors','var_names','maxNumBlocks');
load([pwd '/init_data/sim_vars.mat'], 'namesOfNeurons');

num_rows=6; num_col=3; % can this be automated from numNeurons?

if ~exist('Sim_results','var')
Sim_results = [];
for i = 1:maxNumBlocks
    resultsi = load([pwd '/result/Sim_results' num2str(i) '.mat']).Sim_results;
    Sim_results = [Sim_results, resultsi];
end
end

f = figure;
x_lim = 'auto'; y_lim = 'auto'; 
plotSetting = struct('title', namesOfNeurons, 'x_lim', x_lim, 'y_lim', y_lim, 'num_rows', num_rows, 'num_col', num_col); 
for i = 1 : length(namesOfNeurons)
    subplot(num_rows, num_col, i); 
    title(namesOfNeurons{i}); 
    xlim(x_lim); 
    ylim(y_lim); 
end

menus = varMenus(f); 
allSlider = cell(1, length(var_names));
for i = 1 : length(var_names)
    nextSlider(menus, ['sl_' num2str(i)], var_names{i}, var_vectors{i});
    allSlider{i} = menus.(['sl_' num2str(i)]);
    if (i == ceil(length(var_names)/2) - 1)
        switchHorz(menus);
    end        
end
 
        
allMatrix = var_vectors; 
        
file_related = {Sim_results, var_combos};
data_related = {allSlider, allMatrix}; 
realOrder = {'CorrectOrder', namesOfNeurons}; 
allArg = [file_related(:)', data_related(:)', {plotSetting}, realOrder(:)'];
for i = 1 : length(var_names)
    menus.(['sl_' num2str(i)]).main_slider.Callback = @(eps, ed) displayResult(eps, ed, allArg{:});

end



function displayResult(es, ed, Sim_results, var_combos, sliders, valMat, plotSetting, varargin) %#ok<INUSD>
    realOrderTF = false; 
    if ~isempty(varargin)
        numOpt = length(varargin); 
        if mod(numOpt, 2) ~= 0 
            error('displayResult::Number of options needs to match up with number of arguments in varargin');
        end        
        for i = 1 : 2 : numOpt
            optName = varargin{i};
            optVal = varargin{i + 1}; 
            switch optName
                case 'CorrectOrder' %% need to know the exact name of the fields
                    realOrderTF = true;
                    if ~iscell(optVal) 
                        error('displayResult::Argument for ''CorrectOrder'' needs to be a cell');
                    end
                    realOrder = optVal;
                otherwise 
                    error('displayResult::Invalid Additional Options')
            end
        end        
    end
        
    

    mat_var = zeros(1, length(sliders)); 
    for i = 1 : length(mat_var) 
        mat_var(i) = tmpfun(get(sliders{i}.main_slider, 'value'), valMat{i});
     
    end 
    
    idx = find(ismember(var_combos, mat_var, 'rows'));
    if (length(idx) ~= 1)
        error('Length >< 1  %d', length(idx)); 
    end

    data_struct = Sim_results(idx); 
    real_mat_var = isequal(struct2array(data_struct.vars), mat_var);
    if real_mat_var == 0 
        error('File not correct'); 
    end
    
    %title_list = plotSetting.title; 
    x_lim = plotSetting.x_lim;
    y_lim = plotSetting.y_lim; 
    num_rows = plotSetting.num_rows;
    num_col = plotSetting.num_col;      
    time = data_struct.data.time; 
    fieldNames = setxor(fieldnames(data_struct.data), 'time');
    if realOrderTF  
%         [~, imod, ~] = intersect(realOrder, fieldNames) %% careful 
        fieldNames = realOrder;
    end 
    for i = 1 : length(fieldNames) 
        fN = fieldNames{i}; 
%         tN = title_list{i-1}; 
%         if ~isequal(fN(regexp(fN, '[a-zA-Z0-9]')), tN(regexp(tN, '[a-zA-Z0-9]')))
%             error('Not same field name'); 
%         end 
        subplot(num_rows, num_col, i );    
        plot(time, data_struct.data.(fN)); 
        xlim(x_lim); 
        ylim(y_lim); 
        title(fN);
    end    

        
    for j = 1 : length(sliders)
        sliders{j}.val_text.String = num2str(mat_var(j));
    end

    clear data_struct; 
end
   
   
function val = tmpfun(raw, vect)
    % val = vect(find(abs(raw - vect) == min(abs(raw - vect))));
    new_vect = linspace(min(vect) , max(vect) , length(vect) ); 
    val_loc = find(abs(raw - new_vect) == min(abs(raw - new_vect)));
    val = vect(val_loc);     
end
