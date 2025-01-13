function [pixAll,datCurves,pixAll0,datCheck] = gen_Prop_Evt(mask,dh,dw,propFrame,propGrowCurves,propMoveCurves,option)
    [H,W] = size(mask);
    [ih,iw] = find(mask);

    maxMask = mask;
    for i = 0:propFrame
        ih1 = min(H,max(1,ih + dh*i));
        iw1 = min(W,max(1,iw + dw*i));
        maxMask(sub2ind([H,W],ih1,iw1)) = true;
    end
    
    pixAll = find(maxMask);
    T0 = sum(propMoveCurves{1}>0) + propFrame;
    datCurves = zeros(numel(pixAll),T0);
    curMask = false(H,W);
    for i = 0:propFrame
        ih1 = min(H,max(1,ih + dh*i));
        iw1 = min(W,max(1,iw + dw*i));
        curPix = unique(sub2ind([H,W],ih1,iw1));
        switch option
            case "grow"
                curPix = curPix(~curMask(curPix));
                datCurves(ismember(pixAll,curPix),:) = repmat(propGrowCurves{i + 1},numel(curPix),1);
            case "move"
                datCurves(ismember(pixAll,curPix),:) = max(datCurves(ismember(pixAll,curPix),:),repmat(propMoveCurves{i + 1},numel(curPix),1));
        end
        curMask(curPix) = true;
    end

    
    datCheck = false(H*W,T0);
    datCheck(pixAll,:) = datCurves>0.4;
    datCheck = reshape(datCheck,H,W,T0);
    datCheck = imdilate(datCheck,strel('disk',3));
    pixAll0 = find(sum(datCheck,3));
    datCheck = reshape(datCheck,[],T0);
    datCheck = datCheck(pixAll0,:);

%     datCurves(datCurves<0.2) = 0;
%     dat = zeros(H*W,T0);
%     dat(pixAll,:) = datCurves;
%     dat = reshape(dat,H,W,T0);

end