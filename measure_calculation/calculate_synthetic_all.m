close all;
clear all;
% SNRs = [0:2.5:10,15,20];
SNRs = 10;
methods = {'Suite2P','CaImAn','Begonia','AQuA','AQuA2'};
% levels = 1:6;
levels = 1:5;

options = {'size','location','prop','size_vs_SNR','location_vs_SNR','prop_vs_SNR'};
pRoot = 'D:\Research\AQuA2 prepare\Peer methods\synthetic_unfixed_';
option = options{1};
p0 = [pRoot,option,'_multiPatterns\'];
metrics = cell(numel(levels),numel(SNRs),numel(methods),12);
if strcmp(option(end-2:end),'SNR')
    option = option(1:end-7);
end

for iLevel = 1:numel(levels)
    level = levels(iLevel);
    for iSNR = 1:numel(SNRs)
        SNR = SNRs(iSNR);
        if strcmp(option(1:4),'prop')
            prefix = [p0,'Prop_Level_',num2str(level)];
        else
            prefix = [p0,'Unfixed_',option,'_Level_',num2str(level)];
        end
        for iPattern = 1:4
            load([prefix,'_Pattern_',num2str(iPattern),'_grountTruth.mat']);
            [H,W,T] = size(dat);
            for j = 1:3
                for k = 1:numel(methods)
                    res = load([prefix,'_SNR_',num2str(SNR),'_Pattern_',num2str(iPattern),'_Dataset_',num2str(j),'_',methods{k},'.mat']);
                    if k==1
                        roiLst = cell(size(res.F,1),1);
                        for i = 1:numel(roiLst)
                            roiLst{i} = sub2ind([H,W],res.stat{i}.ypix+1,res.stat{i}.xpix+1);
                        end
                        evtLst = roi2evt_Spike(res.F,res.spks,roiLst,H*W,3,0.2);
                    elseif k == 2
                        roiLst = cell(size(res.roiShape,1),1);
                        for ii = 1:numel(roiLst)
                            a = squeeze(res.roiShape(ii,:,:));
                            roiLst{ii} = find(a>0.03);
                        end
                        evtLst = roi2evt_Spike(res.F_dff,res.S,roiLst,H*W,3,0.2);
                    else
                        evtLst = res.evtLst;
                    end
                    metrics{iLevel,iSNR,k,(iPattern-1)*3+j} = evaluate_Measures_weightedIoU(gtLst,evtLst,dat);
                end
            end
        end
    end
end

save([p0,'metrics.mat'],'metrics');