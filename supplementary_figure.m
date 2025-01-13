close all;
clear all;

fileName = 'Unfixed_location_Level_5_SNR_10_Pattern_1_Dataset_1';
load('Unfixed_location_Level_5_Pattern_1_grountTruth.mat')

[H, W, T] = size(dat);
evtMap = zeros(H, W);

for i = 1:numel(gtLst)
    [ih, iw, it] = ind2sub([H, W, T], gtLst{i});
    ihw = sub2ind([H, W], ih, iw);
    evtMap(ihw) = evtMap(ihw) + 1;
end

figure('Position', [100, 100, 500, 500]);
imagesc(evtMap);
axis off;
set(gca,'position',[0 0 1 1],'units','normalized')
maxEvt = max(evtMap(:));


load([fileName,'_AQuA2.mat'])
H = 512; W = 512; T = 250;
evtMap = zeros(H, W);
for i = 1:numel(evtLst)
    [ih, iw, it] = ind2sub([H, W, T], evtLst{i});
    ihw = sub2ind([H, W], ih, iw);
    evtMap(ihw) = evtMap(ihw) + 1;
end

figure('Position', [100, 100, 500, 500]);
imagesc(evtMap);
axis off;
set(gca,'position',[0 0 1 1],'units','normalized')
clim([0, maxEvt]);

% %%
% close all;
% clear all;
load([fileName,'_AQuA.mat'])
H = 512; W = 512; T = 250;
evtMap = zeros(H, W);
for i = 1:numel(evtLst)
    [ih, iw, it] = ind2sub([H, W, T], evtLst{i});
    ihw = sub2ind([H, W], ih, iw);
    evtMap(ihw) = evtMap(ihw) + 1;
end

figure('Position', [100, 100, 500, 500]);
imagesc(evtMap);
axis off;
set(gca,'position',[0 0 1 1],'units','normalized')
clim([0, maxEvt]);

% %%
% close all;
% clear all;
load([fileName,'_Begonia.mat'])
H = 512; W = 512; T = 250;
evtMap = zeros(H, W);
for i = 1:numel(evtLst)
    [ih, iw, it] = ind2sub([H, W, T], evtLst{i});
    ihw = sub2ind([H, W], ih, iw);
    evtMap(ihw) = evtMap(ihw) + 1;
end

figure('Position', [100, 100, 500, 500]);
imagesc(evtMap);
axis off;
set(gca,'position',[0 0 1 1],'units','normalized')
clim([0, maxEvt]);

%%
%%
load([fileName,'_AQuA2.mat'])
H = 512; W = 512; T = 250;
[cfu_pre1] = cfu.CFU_tmp_function(evtLst, true, [H, W, 1, T],[]);
[cfuRegions1,CFU_lst1] = cfu.CFU_minMeasure(cfu_pre1,true(numel(cfu_pre1.evtIhw),1),0,[H, W, 1, T],0.2, 2,false);
CFUMap = zeros(H, W, 'uint8');
roiLstAQuA2 = cell(numel(cfuRegions1), 1);
for i = 1:numel(cfuRegions1)
    curPix = find(cfuRegions1{i} > 0.5);
    roiLstAQuA2{i} = curPix;
end

visualizeROI(roiLstAQuA2, H, W);

% %%
load([fileName,'_CaImAn.mat'])
roiLstCaImAn = cell(size(roiShape,1),1);
for ii = 1:numel(roiLstCaImAn)
    curMap = false(H, W);
    a = squeeze(roiShape(ii,:,:));
    roiLstCaImAn{ii} = find(a>0.03);
end
% %%
load([fileName,'_Suite2P.mat'])
roiLstSuite2P = cell(size(F,1),1);
for ii = 1:numel(roiLstSuite2P)
    roiLstSuite2P{ii} = sub2ind([H,W],stat{ii}.ypix+1,stat{ii}.xpix+1);
end

visualizeROI(roiLstCaImAn, H, W);
visualizeROI(roiLstSuite2P, H, W);