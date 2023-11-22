classdef varMenus < handle & dynamicprops
    properties
        extra_room      = 75;
        length_slider   = 375;
        width_slider    = 15;
        left_slider     = 160;
        bott_slider     = 40;
        
        left_str        = 50;
        curr_left_str   = 0;
        min_left_str    = 90;        
        max_left_str    = 550;
        
        length_num      = 60;
        length_str      = 100;
        width_str       = 20;
        separation      = 10; 
        
        fig % parent figure
        fontsize        = {'FontSize', 10};
        numSlider_vert  = 0; 
        switchToHorz    = false; 
    end
    
    methods
        function obj = varMenus(fig)
            obj.fig             = fig;
            obj.left_slider     = obj.left_slider + obj.extra_room;
            obj.min_left_str    = obj.min_left_str + obj.extra_room;
            obj.max_left_str    = obj.max_left_str + obj.extra_room;
            obj.curr_left_str   = obj.max_left_str + obj.length_num;
        end
        
        function nextVert(obj)
            if obj.numSlider_vert ~= 0 
                obj.bott_slider = obj.bott_slider +  obj.width_slider + obj.separation;
            end
            obj.numSlider_vert = obj.numSlider_vert + 1; 
        end
        
        % Only after there's gonna be no more vertical nexts
        function switchHorz(obj) 
            obj.switchToHorz = true; 
            obj.numSlider_vert = 0; 
            inc = 1000; 
            obj.bott_slider = 40; 
            incProp(obj, 'left_slider', inc);
            incProp(obj, 'left_str', inc);
            incProp(obj, 'curr_left_str', inc);
            incProp(obj, 'min_left_str', inc);
            incProp(obj, 'max_left_str', inc);   
        end
        
        function incProp(obj, val, inc) 
            obj.(val) = obj.(val) + inc; 
        end 
        function nextSlider(obj, propName, var, val)    
            nextVert(obj); 
            obj.addprop(propName);
            obj.(propName) = slider(obj.fig, var, val); 
            
            update_props = {'bott_slider', 'left_slider', 'left_str', ...
                            'curr_left_str', 'min_left_str', 'max_left_str', ...
                            'numSlider_vert' } ;
            for i = 1 : length(update_props) 
                tmp_prop = update_props{i}; 
                obj.(propName).(tmp_prop)= obj.(tmp_prop); 
            end
               
            setUp(obj.(propName));              
        end
        
        function setCallBackFunction(obj, commonName, func) 
            prop = properties(obj); 
            sliders = prop(find(cellfun(@(x) ~isempty(x), regexp(prop, commonName)))); 
            if isempty(sliders) 
                error('Nothing found under that common name'); 
            end
            for i = 1 : length(sliders) 
                obj.(sliders{i}).main_slider.Callback = func; 
            end                
        end
            
        
    end
end
