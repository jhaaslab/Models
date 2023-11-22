function res = spikingIndOvr(spkt1, spkt2) 
    if isempty(spkt1) || isempty(spkt2) 
        ind1 = 1; 
        ind2 = 1; 
        ov12 = 0;
        ovdt = 0; 
    else 
        relaxt = 5; 
        range1 = [spkt1(1) ; spkt1(end) + relaxt]; 
        range2 = [spkt2(1) ; spkt2(end) + relaxt]; 
        if range1(1) > range2(2) || range1(2) < range2(1) 
            ind1 = 1; 
            ind2 = 1; 
            ov12 = 0;
            ovdt = 0; 
        else 
            t = 1 : 0.001 : max(max(range1, range2)) + (relaxt * 2);
            rect1 = zeros(size(t));
            rect2 = zeros(size(t));
            rect1(fNT(t, range1(1)) : fNT(t, range1(end))) = 20; 
            rect2(fNT(t, range2(1)) : fNT(t, range2(end))) = -10; 
            overlapT = rect1 + rect2; 
            
            ind1 = length(find(overlapT == 20)) / length(find(rect1 == 20)); 
            ind2 = length(find(overlapT == -10)) / length(find(rect2 == -10)); 

            idxOv = find(overlapT == 10);
            ov12 = length(idxOv) / length(find(overlapT ~= 0));
            if  isempty(idxOv)  
                ovdt = 0; 
            else 
                ovdt = t(max(idxOv)) - t(min(idxOv)); 
            end
        end
    end
    
    res.ind1 = ind1; 
    res.ind2 = ind2; 
    res.ov12 = ov12; 
    res.ovdt = ovdt; 
end
function x = fNT(vect, target) % find nearest location in 'vect' that == 'target'
    x = find(abs(vect - target) == min(abs(vect - target))); 
end