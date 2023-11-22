classdef slider < handle & varMenus
    properties
        var % name of the varibles
        val % vector of possible values
        sliderstep 
        main_slider    
        min_text
        max_text
        var_text
        val_text
    end
    
    methods
        function obj = slider(fig, var, val)
            obj             = obj@varMenus(fig);
            obj.var         = var;
            obj.val         = val;
            if length(val) == 1
                 obj.sliderstep  = {'SliderStep', [1, 1]};
            else 
                obj.sliderstep  = {'SliderStep', [1/(length(val)-1), 1]};
            end
        end
        
        function setUp(obj)
            length_slider   = obj.length_slider;
            width_slider    = obj.width_slider; 
            left_slider     = obj.left_slider; 
            bott_slider     = obj.bott_slider;
            
            left_str        = obj.left_str;
            min_left_str    = obj.min_left_str; 
            max_left_str    = obj.max_left_str; 
            length_str      = obj.length_str; 
            width_str       = obj.width_str;
            curr_left_str   = obj.curr_left_str; 
            length_num      = obj.length_num;
            
            f               = obj.fig;
            v               = obj.val; 
            
            sld_pos = [left_slider, bott_slider + 5, length_slider, width_slider];
            min_pos = [min_left_str, bott_slider, length_num,  width_str];
            max_pos = [max_left_str, bott_slider, length_num,  width_str];
            var_pos = [left_str, bott_slider, length_str, width_str];
            val_pos = [curr_left_str, bott_slider, length_str,  width_str];

            obj.main_slider = uicontrol('Parent', f, ... 
                                        'Style', 'slider', ...
                                        'Position', sld_pos,...
                                        'value', min(v), ...
                                        'min', min(v), ...
                                        'max', max(v), ...
                                        obj.sliderstep{:} ); 
                                        
            obj.min_text    = uicontrol('Parent', f, ...
                                        'Style', 'text', ...
                                        'Position', min_pos,...
                                        'String', num2str(min(v)), ...
                                        obj.fontsize{:});
                                    
            obj.max_text    = uicontrol('Parent', f, ...
                                        'Style', 'text', ...
                                        'Position', max_pos,...
                                        'String', num2str(max(v)), ...
                                        obj.fontsize{:});
                                    
            obj.var_text    = uicontrol('Parent', f, ...
                                        'Style', 'text', ...
                                        'Position', var_pos,...
                                        'String', obj.var, ...
                                        obj.fontsize{:});
                                   
            obj.val_text    = uicontrol('Parent', f, ...
                                        'Style', 'text', ...
                                        'Position', val_pos,...
                                        'String', [ '--->     ' num2str(min(v)) ], ...
                                        obj.fontsize{:});
            
        end
    end
end
        
        