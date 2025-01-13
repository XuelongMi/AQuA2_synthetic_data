%% synthetic data
close all;
clear all;
clc;
load('roiMask.mat');
T = 250;
roiLst = bwconncomp(roiMask).PixelIdxList;
impulse = exp(-0.3*(1:20));
impulse = impulse/max(impulse);
impulse = impulse(impulse>0.2);
impulse = [0.4,0.8,impulse];
dur = length(impulse);
SNR = 10;
propFrames = [0:2:10];
levels = 1:6;
propSpeed = 0.15;    % 0.15*radius
SNRs = [0:2.5:10,15,20];

options = {'size','location','prop'};
option = 'prop';
pOut = ['D:\Research\AQuA2 prepare\Peer methods\synthetic_unfixed_',option,'_vs_SNR_multiPatterns\'];
mkdir(pOut);
for xxx = 3
    for iii = 1:4
        groundTruth = zeros(H*W,T);
        dat = zeros(H*W,T);
        level = levels(xxx);
        propFrame = propFrames(level);
        propGrowCurves = cell(propFrame+1,1);
        nEvt = 0;
        for i = 0:propFrame
            curve = [zeros(1,i),0.4,0.8,ones(1,propFrame+1-i),impulse(4:end)];
            propGrowCurves{i+1} = curve;
        end
        propMoveCurves = cell(propFrame+1,1);
        for i = 0:propFrame
            propMoveCurves{i+1} = [zeros(1,i),impulse,zeros(1,propFrame-i)];
        end
    
        for i = 1:numel(roiLst)
            % density sequence
            sequence = randi([0,50],1,T)>48;
            sequence = imdilate(sequence,ones(1,5));  % avoid too dense
            cc = bwconncomp(sequence>0);
            cc = cc.PixelIdxList;
            for t = 1:numel(cc)
                t0 = cc{t}(1);
                t1 = cc{t}(end);
                sequence(t0+1:t1) = 0;
            end
            
            sequence(1:20) = 0;
            sequence(220:end) = 0;
            pix = roiLst{i};
            d00 = sqrt(numel(pix))/2*propSpeed;
            theta00 = rand()*2*pi;
    
            dh00 = ceil(d00*sin(theta00));
            dw00 = ceil(d00*cos(theta00));
    
            
            mask = false(H,W);
            mask(pix) = true;
            
            if rand()>0.5
                option = 'move';
            else
                option = 'grow';
            end
    
            [pixAll,datCurves,pixAll0,datCheck] = gen_Prop_Evt(mask,dh00,dw00,propFrame,propGrowCurves,propMoveCurves,option);
            evtSignal = find(sequence);
            
            for j = 1:numel(evtSignal)
                tStart = evtSignal(j);
                tEnd = tStart + dur -1 + propFrame;
    
                curGroundTruth = groundTruth(pixAll0,tStart:tEnd);
        
                if sum(curGroundTruth(datCheck),[1,2])>0
                    continue;
                end
    
                curGroundTruth = groundTruth(pixAll,tStart:tEnd);
                curGroundTruth(datCurves==1) = true;
                groundTruth(pixAll,tStart:tEnd) = curGroundTruth;
                dat(pixAll,tStart:tEnd) = dat(pixAll,tStart:tEnd) + datCurves;
                nEvt = nEvt + 1;
            end
        
        end
        
        dat = reshape(dat,[H,W,T]);
        
        %% get real groundTruth
        groundTruth = reshape(groundTruth,[H,W,T]);
        cc = bwconncomp(dat>0).PixelIdxList;
        evtMap = zeros(H,W,T);
        nEvt = 1;
        for i = 1:numel(cc)
            pix = cc{i};
            [ih,iw,it] = ind2sub([H,W,T],pix);
            rgh = min(ih):max(ih); H0 = numel(rgh); ih = ih - min(ih) + 1;
            rgw = min(iw):max(iw); W0 = numel(rgw); iw = iw - min(iw) + 1;
            rgt = min(it):max(it); T0 = numel(rgt); it = it - min(it) + 1;
            pix0 = sub2ind([H0,W0,T0],ih,iw,it);
            BW0 = false(H0,W0,T0);
            BW0(pix0) = true;
            scoreMap0 = -dat(rgh,rgw,rgt);
            scoreMap0(~BW0) = 0;
            BW = groundTruth(rgh,rgw,rgt);
            BW(~BW0) = false;
            scoreMap1 = imimposemin(scoreMap0,BW);
            MapOut = watershed(scoreMap1);
            BW0 = false(H0,W0,T0);
            BW0(pix0) = true;
            MapOut(~BW0) = 0;
            waterLst = label2idx(MapOut);
            for ii = 1:numel(waterLst)
                curPix = waterLst{ii};
                [ih,iw,it] = ind2sub([H0,W0,T0],curPix);
                ih = ih + min(rgh) - 1;
                iw = iw + min(rgw) - 1;
                it = it + min(rgt) - 1;
                curPix = sub2ind([H,W,T],ih,iw,it);
                evtMap(curPix) = nEvt;
                nEvt = nEvt + 1;
            end
        end
        
        [x_dir,y_dir,z_dir,t_dir] = dirGenerate(26);
        pix = find(dat>0);
        pix = pix(evtMap(pix)==0);
        while ~isempty(pix)
            [ih0,iw0,it0] = ind2sub([H,W,T],pix);
            for k = 1:numel(x_dir)
                ih = max(1,min(H,ih0 + x_dir(k)));
                iw = max(1,min(W,iw0 + y_dir(k)));
                it = max(1,min(T,it0 + z_dir(k)));
                pixCur = sub2ind([H,W,T],ih,iw,it);
                select = evtMap(pixCur)>0;
                evtMap(pix(select)) = evtMap(pixCur(select));
                ih0 = ih0(~select);
                iw0 = iw0(~select);
                it0 = it0(~select);
                pix = pix(~select);
            end
        end
        gtLst = label2idx(evtMap);
    %     ov = regionMapWithData(gtLst,dat,0.2);
    %     zzshow(ov);
        save([pOut,'Prop_Level_',num2str(level),'_Pattern_',num2str(iii),'_grountTruth.mat'],'gtLst','dat');
        
        %%
        for kkk = 1:numel(SNRs)
            SNR = SNRs(kkk);
            for iDataset = 1:3
                noise = mean(dat(dat>0))/(10^(SNR/20));
                datWithNoise = dat + randn(size(dat))*noise;
                datWithNoise = uint16(datWithNoise/max(datWithNoise(:))*65535);
                writeTif([pOut,'Prop_Level_',num2str(level),'_SNR_',num2str(SNR),'_Pattern_',num2str(iii),'_Dataset_',num2str(iDataset),'.tif'],datWithNoise,0);
            end
        end
    end
end