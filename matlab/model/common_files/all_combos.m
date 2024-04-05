function combo_mat = all_combos(varargin)
num_vars = length(varargin); 
tmp_str = '['; 
for i = 1 : num_vars - 1
    tmp_str = [tmp_str 'd_' num2str(i) ','];
end
tmp_str = [tmp_str 'd_' num2str(num_vars) ']']; 
eval([tmp_str ' = ndgrid(varargin{:});']); 

combo_mat = []; 

for i = 1 : num_vars
    eval(['combo_mat = [combo_mat, ' 'd_' num2str(i) '(:)];']); 
end

end
